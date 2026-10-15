require "test_helper"
require_relative "../../script/file_system"

class FileSystemTest < ScriptTest
  test "reads a TSV file with headers" do
    Tempfile.create([ "books", ".tsv" ]) do |file|
      file.write("title\nBook\n")
      file.flush

      rows = FileSystem.new.read_csv(file.path, col_sep: "\t", headers: true)
      assert_equal [ { "title" => "Book" } ], rows.map(&:to_h)
    end
  end

  test "checks whether a file exists" do
    Tempfile.create("books") do |file|
      assert FileSystem.new.file_exists?(file.path)
      refute FileSystem.new.file_exists?("#{file.path}.missing")
    end
  end
end
