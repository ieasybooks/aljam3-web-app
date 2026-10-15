require "test_helper"

describe "API v1 books" do
  it "lists books with pagination and filters" do
    book = create(:book, title: "Ruby Book")
    Book.index_documents([ book ], true)

    get "/api/v1/books", params: { q: "ruby", page: 1, author: book.author_id, category: book.category_id, library: book.library_id }

    assert_response :success
    assert_kind_of Array, body.fetch("books")
    assert_equal({ "author" => book.author_id, "category" => book.category_id, "library" => book.library_id }, body.fetch("filters"))
    assert body.key?("pagination")
  end

  it "returns a book without file expansion" do
    book = create(:book)

    get "/api/v1/books/#{book.id}"

    assert_response :success
    assert_equal book.id, body.fetch("id")
    refute body.key?("files")
  end

  it "expands a book's files" do
    book = create(:book)
    create(:book_file, book:)

    get "/api/v1/books/#{book.id}", params: { expand: [ "files" ] }

    assert_response :success
    assert body.key?("files")
  end

  it "returns not found for hidden books" do
    book = create(:book, hidden: true)

    get "/api/v1/books/#{book.id}"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
