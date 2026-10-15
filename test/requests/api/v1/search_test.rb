require "test_helper"

describe "API v1 search" do
  it "returns pages for a text query" do
    page = create(:page, content: "Islam is a religion")
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Islam" }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
    assert body.key?("pagination")
  end

  it "accepts a library filter" do
    library = create(:library)
    page = create(:page, content: "Quran verse", file: create(:book_file, book: create(:book, library:)))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Quran", library: library.id }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  it "accepts a book filter" do
    book = create(:book)
    page = create(:page, content: "Hadith text", file: create(:book_file, book:))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Hadith", books: [ book.id ] }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  it "accepts an author filter" do
    author = create(:author)
    book = create(:book, author:)
    page = create(:page, content: "Scholar writing", file: create(:book_file, book:))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Scholar", authors: [ author.id ] }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  it "accepts a category filter" do
    category = create(:category)
    book = create(:book, category:)
    page = create(:page, content: "Fiqh ruling", file: create(:book_file, book:))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Fiqh", categories: [ category.id ] }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  it "honors a page limit" do
    file = create(:book_file)
    pages = create_list(:page, 5, file:, content: "Test content")
    Page.index_documents(pages, true)

    get "/api/v1/search", params: { q: "Test", limit: 2 }

    assert_response :success
    assert_equal 2, body.dig("pagination", "limit")
  end

  it "caps a large page limit at 1000" do
    page = create(:page, content: "Large limit test")
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Large", limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
