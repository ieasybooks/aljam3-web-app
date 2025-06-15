require_relative "books_importer"

if __FILE__ == $PROGRAM_NAME
  begin
    BooksImporter.new.run
  rescue BooksImporter::Error => e
    puts "Error: #{e.message}"
    exit 1
  end
end
