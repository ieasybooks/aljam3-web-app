# frozen_string_literal: true

require "addressable/uri"
require "json"
require "optparse"
require "tqdm"

require_relative "file_system"
require_relative "ssh_client"

class BooksImporter
  class Error < StandardError; end
  class ValidationError < Error; end

  def initialize(file_system: FileSystem.new, ssh_client: SshClient.new, output: $stdout, argv: ARGV)
    @file_system = file_system
    @ssh_client = ssh_client
    @output = output
    @argv = argv
  end

  def run
    options = parse_options
    index_data = read_index_file(options[:index_path])

    index_data.tqdm.each_with_index do |row, index|
      next if (index + 1) <= options[:skip_first]

      process_book_row(row, index, options)
    end
  end

  private

  def parse_options
    options = {}
    option_parser = create_option_parser(options)

    if help_requested?
      show_help(option_parser, nil)
      exit
    end

    option_parser.parse!(@argv)
    validate_and_process_options(options, option_parser)
  end

  def create_option_parser(options)
    OptionParser.new do |opts|
      opts.banner = "Usage: ruby lib/tools/import_books.rb [options]"

      opts.on("--index-path=INDEX_PATH", "[REQUIRED] Library's TSV index path.") { options[:index_path] = it }
      opts.on("--huggingface-library-id=HUGGINGFACE_LIBRARY_ID", "[REQUIRED] HuggingFace Dataset library ID.") { options[:huggingface_library_id] = it }
      opts.on("--aljam3-library-id=ALJAM3_LIBRARY_ID", Integer, "[REQUIRED] Aljam3 library ID.") { options[:aljam3_library_id] = it }
      opts.on("--server-ip=SERVER_IP", "[REQUIRED] Server IP.") { options[:server_ip] = it }
      opts.on("--server-username=SERVER_USERNAME", "[REQUIRED] Server username.") { options[:server_username] = it }
      opts.on("--skip-first=SKIP_FIRST", Integer, "Skip the first N books.") { options[:skip_first] = it.to_i }
      opts.on("--dry-run", "Run the script without actually importing the books.") { options[:dry_run] = true }
      opts.on("-h", "--help", "Show this help message")
    end
  end

  def help_requested? = @argv.include?("--help") || @argv.include?("-h")

  def show_help(option_parser, error_message)
    @output.puts "Error: #{error_message}\n" if error_message
    @output.puts option_parser

    @output.puts "\nExamples:"
    @output.puts "  ruby lib/tools/import_books.rb \\"
    @output.puts "    --index-path=path/to/index.tsv \\"
    @output.puts "    --huggingface-library-id=ieasybooks-org/shamela-waqfeya-library \\"
    @output.puts "    --aljam3-library-id=3 \\"
    @output.puts "    --server-ip=127.0.0.1 \\"
    @output.puts "    --server-username=root \\"
    @output.puts "    --skip-first=100"
  end

  def validate_and_process_options(options, option_parser)
    required_args = [ :index_path, :huggingface_library_id, :aljam3_library_id, :server_ip, :server_username ]
    missing_args = required_args.select { options[it].nil? }

    if missing_args.any?
      show_help(option_parser, "Missing required arguments: #{missing_args.join(', ')}")
      exit 1
    end

    options[:index_path] = File.expand_path(options[:index_path])

    unless @file_system.file_exists?(options[:index_path])
      raise ValidationError, "Index file does not exist: #{options[:index_path]}"
    end

    options[:skip_first] = options[:skip_first] || -1

    options
  end

  def read_index_file(path) = @file_system.read_csv(path, col_sep: "\t", headers: true)

  def process_book_row(row, index, options)
    book_data = extract_book_data(row)

    unless valid_book_data?(book_data)
      @output.puts "Skipping book \"#{row["title"]}\" (#{index}) because it has different number of files in different formats"

      return
    end

    return if options[:dry_run]

    import_book(row, book_data, options.except(:index_path))
  rescue RuntimeError => e
    @output.puts "ERROR: Failed to import book '#{row["title"]}': #{e.message}"
  end

  def extract_book_data(row)
    {
      pdf_paths: parse_json_paths(row["pdf_paths"]),
      txt_paths: parse_json_paths(row["txt_paths"]),
      docx_paths: parse_json_paths(row["docx_paths"])
    }
  end

  def parse_json_paths(paths_string)
    paths_string = paths_string.gsub("'", '"') if paths_string[..1] == "['"

    JSON.parse(paths_string)
  end

  def valid_book_data?(book_data)
    [ book_data[:pdf_paths].size, book_data[:txt_paths].size, book_data[:docx_paths].size ].uniq.size == 1
  end

  def import_book(row, book_data, options)
    urls = build_urls(book_data, options[:huggingface_library_id])
    import_command = build_import_command(row, urls, options[:aljam3_library_id])
    docker_command = build_docker_command(import_command)

    @ssh_client.execute_with_output(options[:server_ip], options[:server_username], docker_command) { @output.puts(it) }
  end

  def build_urls(book_data, huggingface_library_id)
    {
      pdf_urls: book_data[:pdf_paths].sort.map { path_to_url(it, huggingface_library_id) },
      txt_urls: book_data[:txt_paths].sort.map { path_to_url(it, huggingface_library_id) },
      docx_urls: book_data[:docx_paths].sort.map { path_to_url(it, huggingface_library_id) }
    }
  end

  def path_to_url(path, huggingface_library_id)
    Addressable::URI.encode("https://huggingface.co/datasets/#{huggingface_library_id}/resolve/main/#{path[2..]}")
  end

  def build_import_command(row, urls, aljam3_library_id)
    command = [
      "bundle exec rake db:import_book --",
      "--title=\"#{row["title"]}\"",
      "--author=\"#{row["author"]}\"",
      "--category=\"#{row["category"]}\"",
      "--pages=#{row["pages"]}",
      "--library-id=#{aljam3_library_id}",
      "--pdf-urls=\"#{urls[:pdf_urls].join(";")}\"",
      "--txt-urls=\"#{urls[:txt_urls].join(";")}\"",
      "--docx-urls=\"#{urls[:docx_urls].join(";")}\""
    ]

    command << "--volumes=#{row["volumes"]}" unless row["volumes"].nil? || row["volumes"].empty?

    command.join(" ")
  end

  def build_docker_command(command) = "docker exec $(docker ps -aqf \"name=aljam3-web\" | head -n 1) #{command}"
end
