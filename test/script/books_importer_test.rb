require "test_helper"
require_relative "../../script/books_importer"

class BooksImporterTest < ScriptTest
  class FileSystemDouble
    attr_accessor :exists, :rows
    attr_reader :reads

    def initialize(exists: true, rows: [])
      @exists = exists
      @rows = rows
      @reads = []
    end

    def file_exists?(path)
      @checked_path = path
      exists
    end

    def read_csv(path, **options)
      @reads << [ path, options ]
      rows
    end
  end

  class SshClientDouble
    attr_reader :calls
    attr_accessor :error

    def initialize
      @calls = []
    end

    def execute_with_output(server_ip, username, command)
      raise error if error

      @calls << [ server_ip, username, command ]
      yield("Import successful") if block_given?
    end
  end

  setup do
    @output = StringIO.new
    @file_system = FileSystemDouble.new
    @ssh_client = SshClientDouble.new
  end

  test "prints help for either help flag" do
    [ "--help", "-h" ].each do |flag|
      error = assert_raises(SystemExit) { importer(argv: [ flag ]).run }
      assert_equal 0, error.status
      assert_includes @output.string, "Usage: ruby lib/tools/import_books.rb"
      @output.truncate(0)
      @output.rewind
    end
  end

  test "rejects missing required arguments" do
    error = assert_raises(SystemExit) { importer(argv: [ "--index-path=/tmp/index.tsv" ]).run }

    assert_equal 1, error.status
    assert_includes @output.string, "Missing required arguments"
  end

  test "rejects a missing index file" do
    @file_system.exists = false

    error = assert_raises(BooksImporter::ValidationError) do
      importer(argv: valid_argv).run
    end

    assert_includes error.message, "Index file does not exist"
  end

  test "expands the index path and reads TSV data" do
    @file_system.rows = []

    importer(argv: valid_argv(index_path: "~/books.tsv")).run

    expanded = File.expand_path("~/books.tsv")
    assert_equal [ expanded, { col_sep: "\t", headers: true } ], @file_system.reads.first
  end

  test "imports rows and builds encoded Docker commands" do
    @file_system.rows = [ valid_row.merge("volumes" => "3"), valid_row(title: "Second Book", pdf_paths: '["./book/file 2.pdf"]', txt_paths: '["./book/file 2.txt"]', docx_paths: '["./book/file 2.docx"]') ]

    importer(argv: valid_argv).run

    assert_equal 2, @ssh_client.calls.size
    server_ip, username, command = @ssh_client.calls.first
    assert_equal [ "127.0.0.1", "root" ], [ server_ip, username ]
    assert_includes command, 'docker exec $(docker ps -aqf "name=aljam3-web" | head -n 1)'
    assert_includes command, '--title="Test Book"'
    assert_includes command, "--volumes=3"
    assert_includes command, "file%20one.pdf"
    assert_includes @output.string, "Import successful"
  end

  test "supports single-quoted paths, dry runs, and skipping rows" do
    @file_system.rows = [ valid_row(title: "Skipped"), valid_row(title: "Imported", pdf_paths: "['./book/file.pdf']", txt_paths: "['./book/file.txt']", docx_paths: "['./book/file.docx']") ]

    importer(argv: valid_argv(skip_first: 1, dry_run: true)).run

    assert_empty @ssh_client.calls
    assert_empty @output.string
  end

  test "logs invalid rows and continues after SSH failures" do
    invalid = valid_row(title: "Invalid", txt_paths: "[]")
    @file_system.rows = [ invalid, valid_row(title: "Fails") ]
    @ssh_client.error = RuntimeError.new("SSH connection failed")

    importer(argv: valid_argv).run

    assert_includes @output.string, 'Skipping book "Invalid"'
    assert_includes @output.string, "SSH connection failed"
  end

  private

  def importer(argv: valid_argv)
    BooksImporter.new(file_system: @file_system, ssh_client: @ssh_client, output: @output, argv:)
  end

  def valid_argv(index_path: "/tmp/index.tsv", skip_first: nil, dry_run: false)
    args = [
      "--index-path=#{index_path}",
      "--huggingface-library-id=test/library",
      "--aljam3-library-id=1",
      "--server-ip=127.0.0.1",
      "--server-username=root"
    ]
    args << "--skip-first=#{skip_first}" if skip_first
    args << "--dry-run" if dry_run
    args
  end

  def valid_row(title: "Test Book", pdf_paths: '["./book/file one.pdf"]', txt_paths: '["./book/file one.txt"]', docx_paths: '["./book/file one.docx"]')
    {
      "title" => title,
      "author" => "Test Author",
      "category" => "Test Category",
      "pages" => "100",
      "pdf_paths" => pdf_paths,
      "txt_paths" => txt_paths,
      "docx_paths" => docx_paths
    }
  end
end
