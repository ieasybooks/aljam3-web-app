require "optparse"

namespace :db do
  desc "Import a book"
  task import_book: :environment do
    show_help = lambda do |parser, error_message|
      if error_message
        puts "Error: #{error_message}"
        puts ""
      end

      puts parser
      puts ""
      puts "Examples:"
      puts "  rake db:import_book -- \\"
      puts "    --title 'صحيح البخاري' \\"
      puts "    --author 'محمد بن اسماعيل البخاري' \\"
      puts "    --category 'الحديث' \\"
      puts "    --pages 180 \\"
      puts "    --volumes 1 \\"
      puts "    --library-id 1 \\"
      puts "    --pdf-urls 'https://example.com/file with spaces.pdf;https://example.com/another file.pdf' \\"
      puts "    --pdf-sizes '15.4;10.1' \\"
      puts "    --txt-urls 'https://example.com/file with spaces.txt;https://example.com/another file.txt' \\"
      puts "    --txt-sizes '0.3;0.1' \\"
      puts "    --docx-urls 'https://example.com/file with spaces.docx;https://example.com/another file.docx' \\"
      puts "    --docx-sizes '1.3;0.9' \\"
      puts "    --txt-paths '/path/to/file with spaces.txt;/path/to/another file.txt'"
    end

    split_list = lambda { it.split(";").map(&:strip).reject(&:empty?) }

    options = {}

    option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: rake db:import_book -- [options]"

      opts.on("--title TITLE", "Book title (required)") { options[:title] = it }
      opts.on("--author AUTHOR", "Book author (required)") { options[:author] = it }
      opts.on("--category CATEGORY", "Book category (required)") { options[:category] = it }
      opts.on("--pages PAGES", Integer, "Number of pages (required)") { options[:pages] = it }
      opts.on("--volumes VOLUMES", Integer, "Number of volumes (defaults to -1)") { options[:volumes] = it }
      opts.on("--library-id LIBRARY_ID", Integer, "Library ID (required)") { options[:library_id] = it }
      opts.on("--pdf-urls PDF_URLS", "Semicolon-separated list of PDF file URLs (use semicolons to separate files)") { options[:pdf_urls] = split_list.call(it) }
      opts.on("--pdf-sizes PDF_SIZES", "Semicolon-separated list of PDF file sizes in MB (use semicolons to separate files)") { options[:pdf_sizes] = split_list.call(it) }
      opts.on("--txt-urls TXT_URLS", "Semicolon-separated list of TXT file URLs (use semicolons to separate files)") { options[:txt_urls] = split_list.call(it) }
      opts.on("--txt-sizes TXT_SIZES", "Semicolon-separated list of TXT file sizes in MB (use semicolons to separate files)") { options[:txt_sizes] = split_list.call(it) }
      opts.on("--docx-urls DOCX_URLS", "Semicolon-separated list of DOCX file URLs (use semicolons to separate files)") { options[:docx_urls] = split_list.call(it) }
      opts.on("--docx-sizes DOCX_SIZES", "Semicolon-separated list of DOCX file sizes in MB (use semicolons to separate files)") { options[:docx_sizes] = split_list.call(it) }
      opts.on("--txt-paths TXT_PATHS", "Semicolon-separated list of local TXT file paths (use semicolons to separate files)") { options[:txt_paths] = split_list.call(it) }

      opts.on("-h", "--help", "Show this help message")
    end

    if ARGV.include?("--help") || ARGV.include?("-h")
      show_help.call(option_parser, nil); exit
    end

    begin
      option_parser.parse!(ARGV)
    rescue => e
      show_help.call(option_parser, "Error: #{e.message}"); exit 1
    end

    options[:volumes] ||= -1

    required_args = [ :title, :author, :category, :pages, :library_id, :pdf_urls, :pdf_sizes, :txt_urls, :txt_sizes, :docx_urls, :docx_sizes, :txt_paths ]
    missing_args = required_args.select { |arg| options[arg].nil? }
    if missing_args.any?
      show_help.call(option_parser, "Error: Missing required arguments: #{missing_args.join(', ')}"); exit 1
    end

    if [
      options[:pdf_urls].size,
      options[:pdf_sizes].size,
      options[:txt_urls].size,
      options[:txt_sizes].size,
      options[:docx_urls].size,
      options[:docx_sizes].size,
      options[:txt_paths].size
    ].uniq.size != 1
      puts "Error: The number of URLs, sizes, and paths must be the same for all file types"; exit 1
    end

    unless Library.exists?(options[:library_id].to_i)
      puts "Error: Library with ID '#{options[:library_id]}' not found"; exit 1
    end

    begin
      book = Book.create!(
        title: options[:title],
        author: options[:author],
        category: options[:category],
        pages: options[:pages],
        volumes: options[:volumes],
        library_id: options[:library_id]
      )

      book_files = []

      [
        options[:pdf_urls],
        options[:pdf_sizes],
        options[:txt_urls],
        options[:txt_sizes],
        options[:docx_urls],
        options[:docx_sizes]
      ].transpose.each do |pdf_url, pdf_size, txt_url, txt_size, docx_url, docx_size|
        begin
          book_files << book.files.create!(
            pdf_url:,
            pdf_size:,
            txt_url:,
            txt_size:,
            docx_url:,
            docx_size:
          )
        rescue => e
          puts "An error occurred while creating BookFile for '#{pdf_url}': #{e.message}"; exit 1
        end
      end

      options[:txt_paths].each_with_index do |txt_path, index|
        book_file = book_files[index]
        pages = File.read(txt_path).split(/\r?\nPAGE_SEPARATOR\r?\n/)

        book_file.pages.insert_all(
          pages.map.with_index(1) do |page, jndex|
            {
              content: page.strip,
              number: jndex,
              book_file_id: book_file.id
            }
          end
        )
      end
    rescue => e
      puts "An error occurred while creating the book: #{e.message}"; exit 1
    end
  end
end
