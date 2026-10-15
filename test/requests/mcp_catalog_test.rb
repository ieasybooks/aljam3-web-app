require "test_helper"

class McpCatalogTest < ApplicationTest
  setup do
    host! "aljam3.com"
    https!
  end

  test "filters books and excludes hidden records" do
    book = create(:book)
    create(:book, author: book.author, category: book.category)
    create(:book, author: book.author, library: book.library)
    create(:book, category: book.category, library: book.library)
    create(:book, author: book.author, category: book.category, library: book.library, hidden: true)
    create(:book, author: create(:author, hidden: true))

    data = mcp_data("list_books", author_id: book.author_id, category_id: book.category_id, library_id: book.library_id)
    assert_equal [ book.id ], data.fetch("books").pluck("id")
    assert_equal book.author_id, data.dig("books", 0, "author", "id")
    assert_equal 4, mcp_data("list_books").fetch("books").size
  end

  test "paginates books deterministically and serializes the result" do
    books = create_list(:book, 3, title: "الفقه")
    result = mcp_call("list_books", per_page: 2)

    assert_equal JSON.parse(result.dig("content", 0, "text")), result.fetch("structuredContent")
    assert_equal books.first(2).map(&:id), result.dig("structuredContent", "books").pluck("id")
    assert_equal 2, result.dig("structuredContent", "pagination", "next_page")
    last = mcp_data("list_books", per_page: 2, page: 2)
    assert_equal [ books.last.id ], last.fetch("books").pluck("id")
    assert_nil last.dig("pagination", "next_page")
  end

  test "returns book metadata and files in reading order" do
    book = create(:book, volumes: -1)
    first = create(:book_file, book:)
    second = create(:book_file, book:)
    create(:page, file: first, number: 7)
    create(:page, file: first, number: 3)

    data = mcp_data("get_book", id: book.id, per_page: 1, locale: "en")
    assert_equal book.title, data.dig("book", "title")
    assert_nil data.dig("book", "volumes")
    assert_equal 2, data.dig("book", "files_count")
    assert_equal first.id, data.dig("files", 0, "id")
    assert_equal 3, data.dig("files", 0, "first_page_number")
    assert_equal 2, data.dig("pagination", "next_page")
    assert_equal second.id, mcp_data("get_book", id: book.id, per_page: 1, page: 2).dig("files", 0, "id")
  end

  test "exposes collection limits and stable identifiers" do
    create_list(:author, 101)
    data = mcp_data("list_authors", page: 100, per_page: 1)
    assert_equal 1, data.fetch("authors").size
    assert_equal true, data.dig("pagination", "limit_reached")
  end

  test "lists catalog records with IDs usable as filters" do
    book = create(:book)
    assert_equal book.author_id, mcp_data("list_authors").fetch("authors").find { |author| author["id"] == book.author_id }["id"]
    assert_equal book.category_id, mcp_data("list_categories").fetch("categories").find { |category| category["id"] == book.category_id }["id"]
    assert mcp_data("list_libraries").fetch("libraries").any? { |library| library["id"] == book.library_id }
  end

  test "returns not_found for missing and hidden resources" do
    hidden = create(:book, hidden: true)
    hidden_author_book = create(:book, author: create(:author, hidden: true))

    [ hidden, hidden_author_book ].each do |book|
      file = create(:book_file, book:)
      create(:page, file:, number: 1)
      assert_equal true, mcp_call("get_book", id: book.id).fetch("isError")
      assert_equal "not_found", mcp_data("get_page", file_id: file.id, page_number: 1).dig("error", "code")
    end
    assert_equal "not_found", mcp_data("get_book", id: 9_223_372_036_854_775_807).dig("error", "code")
  end

  test "reads page chunks and navigates neighboring pages" do
    file = create(:book_file)
    create(:page, file:, number: 2)
    page = create(:page, file:, number: 5, content: "إنما الأعمال بالنيات\nوإنما لكل امرئ ما نوى")
    create(:page, file:, number: 9)

    data = mcp_data("get_page", file_id: file.id, page_number: 5, max_chars: 10, locale: "ur")
    assert_equal page.content.first(10), data.dig("text", "content")
    assert_equal 10, data.dig("text", "next_offset")
    assert_equal({ "previous_page_number" => 2, "next_page_number" => 9 }, data.fetch("navigation"))
    remaining = mcp_data("get_page", file_id: file.id, page_number: 5, offset: 10)
    assert_equal page.content[10..], remaining.dig("text", "content")
    assert_nil remaining.dig("text", "next_offset")
  end

  test "reports missing pages and bounds long or empty text" do
    page = create(:page, number: 1, content: "أ" * 12_001)
    assert_equal "not_found", mcp_data("get_page", file_id: page.book_file_id, page_number: 2).dig("error", "code")
    data = mcp_data("get_page", file_id: page.book_file_id, page_number: 1, max_chars: 12_000)
    assert_equal 12_000, data.dig("text", "content").length
    assert_equal 12_000, data.dig("text", "next_offset")

    page.update_columns(content: "")
    empty = mcp_data("get_page", file_id: page.book_file_id, page_number: 1)
    assert_equal "", empty.dig("text", "content")
    assert_equal "invalid_parameter", mcp_data("get_page", file_id: page.book_file_id, page_number: 1, offset: 1).dig("error", "code")
  end

  test "does not mutate analytics while reading a page" do
    page = create(:page, number: 1)
    snapshot = [ page.file.book.reload.views_count, SearchQuery.count, SearchClick.count ]
    mcp_call("get_page", file_id: page.book_file_id, page_number: 1)

    assert_equal snapshot, [ page.file.book.reload.views_count, SearchQuery.count, SearchClick.count ]
  end

  test "reports backend failures without leaking details and restores locale" do
    PublicCatalog.stubs(:books).raises(StandardError, "private connection details")
    Rails.error.stubs(:report)
    original_locale = I18n.locale

    result = mcp_call("list_books", locale: "en")

    assert_equal true, result.fetch("isError")
    assert_equal "internal_error", result.dig("structuredContent", "error", "code")
    refute_includes result.to_json, "private connection details"
    assert_equal original_locale, I18n.locale
  end
end
