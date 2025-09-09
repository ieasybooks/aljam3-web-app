json.partial! "api/v1/books/book", book: @book

if params[:expand]&.include?("files")
  json.files do
    json.array! @files, partial: "api/v1/files/file", as: :file
  end
end
