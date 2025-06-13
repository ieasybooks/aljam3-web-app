require "optparse"
require "open-uri"
require "tempfile"

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
      puts '    --title="صحيح البخاري" \\'
      puts '    --author="محمد بن اسماعيل البخاري" \\'
      puts '    --category="الحديث" \\'
      puts "    --pages=180 \\"
      puts "    --volumes=1 \\"
      puts "    --library-id=1 \\"
      puts '    --pdf-urls="https://example.com/file with spaces.pdf;https://example.com/another file.pdf" \\'
      puts '    --txt-urls="https://example.com/file with spaces.txt;https://example.com/another file.txt" \\'
      puts '    --docx-urls="https://example.com/file with spaces.docx;https://example.com/another file.docx"'
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
      opts.on("--txt-urls TXT_URLS", "Semicolon-separated list of TXT file URLs (use semicolons to separate files)") { options[:txt_urls] = split_list.call(it) }
      opts.on("--docx-urls DOCX_URLS", "Semicolon-separated list of DOCX file URLs (use semicolons to separate files)") { options[:docx_urls] = split_list.call(it) }

      opts.on("-h", "--help", "Show this help message")
    end

    if ARGV.include?("--help") || ARGV.include?("-h")
      show_help.call(option_parser, nil); exit
    end

    begin
      option_parser.parse!(ARGV[2..])
    rescue => e
      show_help.call(option_parser, e.message); exit 1
    end

    options[:volumes] ||= -1

    required_args = [ :title, :author, :category, :pages, :library_id, :pdf_urls, :txt_urls, :docx_urls ]
    missing_args = required_args.select { options[it].nil? }
    if missing_args.any?
      show_help.call(option_parser, "Missing required arguments: #{missing_args.join(', ')}"); exit 1
    end

    if [ options[:pdf_urls].size, options[:txt_urls].size, options[:docx_urls].size ].uniq.size != 1
      puts "Error: The number of URLs must be the same for all file types"; exit 1
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

      [ options[:pdf_urls], options[:txt_urls], options[:docx_urls] ].transpose.each do |pdf_url, txt_url, docx_url|
        begin
          book_files << book.files.create!(pdf_url:, txt_url:, docx_url:)
        rescue => e
          puts "An error occurred while creating BookFile for '#{pdf_url}': #{e.message}"; exit 1
        end
      end

      options[:txt_urls].each_with_index do |txt_url, index|
        book_file = book_files[index]

        begin
          temp_file = Tempfile.new([ "book_content", ".txt" ])

          URI.open(txt_url) { temp_file.write(it.read) }
          temp_file.rewind

          book_file.pages.insert_all(
            temp_file.read.split(/\r?\nPAGE_SEPARATOR\r?\n/).map.with_index(1) do |page, jndex|
              {
                content: page.strip,
                number: jndex,
                book_file_id: book_file.id
              }
            end
          )
        rescue => e
          puts "An error occurred while downloading or processing TXT file from '#{txt_url}': #{e.message}"; exit 1
        ensure
          temp_file.close
          temp_file.unlink
        end
      end
    rescue => e
      puts "An error occurred while creating the book: #{e.message}"; exit 1
    end
  end
end
