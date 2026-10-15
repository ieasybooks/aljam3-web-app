require "test_helper"

class ApiV1SearchTest < ApplicationTest
  test "returns pages for a text query" do
    page = create(:page, content: "Islam is a religion")
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Islam" }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
    assert body.key?("pagination")
  end

  test "accepts a library filter" do
    library = create(:library)
    page = create(:page, content: "Quran verse", file: create(:book_file, book: create(:book, library:)))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Quran", library: library.id }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  test "accepts a book filter" do
    book = create(:book)
    page = create(:page, content: "Hadith text", file: create(:book_file, book:))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Hadith", books: [ book.id ] }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  test "accepts author and category filters" do
    author = create(:author)
    category = create(:category)
    book = create(:book, author:, category:)
    page = create(:page, content: "Scholar writing", file: create(:book_file, book:))
    Page.index_documents([ page ], true)

    get "/api/v1/search", params: { q: "Scholar", authors: [ author.id ], categories: [ category.id ] }

    assert_response :success
    assert_kind_of Array, body.fetch("pages")
  end

  test "honors and caps the page limit" do
    file = create(:book_file)
    pages = create_list(:page, 5, file:, content: "Test content")
    Page.index_documents(pages, true)

    get "/api/v1/search", params: { q: "Test", limit: 2 }
    assert_equal 2, body.dig("pagination", "limit")

    get "/api/v1/search", params: { q: "Test", limit: 1500 }
    assert_equal 1000, body.dig("pagination", "limit")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
