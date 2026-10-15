require "test_helper"
require_relative "../../script/file_system"

class FileSystemTest < ScriptTest
  test "reads CSV files with the requested options" do
    CSV.expects(:read).with("books.tsv", headers: true).returns([ { "title" => "Book" } ])

    assert_equal [ { "title" => "Book" } ], FileSystem.new.read_csv("books.tsv", headers: true)
  end

  test "checks whether a file exists" do
    File.expects(:exist?).with("books.tsv").returns(true)

    assert FileSystem.new.file_exists?("books.tsv")
  end
end
