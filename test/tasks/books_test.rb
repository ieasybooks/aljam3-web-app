require "test_helper"

class BooksTaskTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
  include TaskSupport

  setup do
    @library = create(:library)
    @original_argv = ARGV.dup
  end

  def teardown
    ARGV.replace(@original_argv)
    super
  end

  test "imports the book and its pages" do
    ARGV.replace(build_argv)
    URI.stubs(:open).yields(StringIO.new("First page.\nPAGE_SEPARATOR\nSecond page."))

    assert_difference("Book.count", 1) do
      assert_difference("BookFile.count", 2) do
        assert_difference("Page.count", 2) { task("db:import_book").invoke }
      end
    end

    assert_equal [ "First page.", "Second page." ], Page.order(:number).pluck(:content)
  end

  test "reports missing arguments" do
    ARGV.replace(build_argv[0..-3])

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "Error: Missing required arguments: docx_urls"
  end

  test "reports an unknown library" do
    ARGV.replace(build_argv(library_id: "999999"))

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "Error: Library with ID '999999' not found"
  end

  test "reports mismatched file URL counts" do
    ARGV.replace(build_argv(txt_urls: "https://example.com/only.txt"))

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "The number of URLs must be the same"
  end

  test "reports download failures" do
    ARGV.replace(build_argv)
    URI.stubs(:open).raises(URI::InvalidURIError)

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "An error occurred while downloading or processing TXT file"
  end

  test "reports option parsing errors" do
    ARGV.replace(build_argv)
    OptionParser.any_instance.stubs(:parse!).raises(OptionParser::InvalidOption, "invalid option")

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "Error: invalid option"
  end

  test "reports a book creation failure" do
    ARGV.replace(build_argv)
    Book.stubs(:create!).raises(StandardError, "database is unavailable")

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "An error occurred while creating the book"
  end

  test "reports a book file creation failure" do
    ARGV.replace(build_argv)
    files = mock("book files")
    files.expects(:create!).raises(StandardError, "invalid file")
    Book.any_instance.stubs(:files).returns(files)

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "An error occurred while creating BookFile"
  end

  test "shows help" do
    ARGV.replace([ "--help" ])

    output = capture_io { assert_raises(SystemExit) { task("db:import_book").invoke } }.first
    assert_includes output, "Usage: rake db:import_book"
  end

  private

  def build_argv(library_id: @library.id.to_s, txt_urls: "https://example.com/file.txt;https://example.com/another.txt")
    [
      "db:import_book", "--", "--title", "صحيح البخاري", "--author", "محمد بن اسماعيل البخاري",
      "--category", "الحديث", "--pages", "180", "--volumes", "1", "--library-id", library_id,
      "--pdf-urls", "https://example.com/file.pdf;https://example.com/another.pdf",
      "--txt-urls", txt_urls,
      "--docx-urls", "https://example.com/file.docx;https://example.com/another.docx"
    ]
  end
end
