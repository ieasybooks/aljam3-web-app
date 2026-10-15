require "test_helper"

class McpSearchTest < ApplicationTest
  setup do
    host! "aljam3.com"
    https!
    [ Page, Book, Author, Category ].each { |model| model.clear_index!(true) }
  end

  test "finds a passage and reads its source context" do
    content = ("مقدمة الكتاب " * 200) + "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى" + (" خاتمة " * 200)
    page = create(:page, number: 12, content:)
    create(:page, file: page.file, number: 11, content: "باب النية")
    create(:page, file: page.file, number: 13, content: "شرح الحديث")
    Page.index_documents([ page ], true)

    result = mcp_data("search", q: "الأعمال بالنيات").fetch("results").sole
    assert_includes result.fetch("excerpt"), "إنما الأعمال بالنيات"
    assert_equal true, result.fetch("excerpt_truncated")
    assert_equal content[result.fetch("excerpt_offset"), 1_000], result.fetch("excerpt")
    assert_equal page.id, result.fetch("id")

    source = mcp_data("get_page", file_id: page.book_file_id, page_number: 12)
    assert_equal content, source.dig("text", "content")
    assert_equal({ "previous_page_number" => 11, "next_page_number" => 13 }, source.fetch("navigation"))
  end

  test "combines filters and paginates search results" do
    book = create(:book)
    matching = create(:page, content: "أحكام الصلاة", file: create(:book_file, book:))
    others = [
      create(:book, author: book.author, category: book.category),
      create(:book, author: book.author, library: book.library),
      create(:book, category: book.category, library: book.library)
    ].map { |other| create(:page, content: "أحكام الصلاة", file: create(:book_file, book: other)) }
    Page.index_documents([ matching, *others ], true)
    filters = { book_id: book.id, author_id: book.author_id, category_id: book.category_id, library_id: book.library_id }

    assert_equal [ matching.id ], mcp_data("search", q: "الصلاة", **filters).fetch("results").pluck("id")
    first = mcp_data("search", q: "الصلاة", per_page: 2)
    last = mcp_data("search", q: "الصلاة", per_page: 2, page: 2)
    assert_equal 2, first.dig("pagination", "next_page")
    assert_nil last.dig("pagination", "next_page")
    assert_equal [ matching.id, *others.map(&:id) ].sort, (first.fetch("results") + last.fetch("results")).pluck("id").sort
  end

  test "searches titles, authors, categories and no-match queries" do
    book = create(:book, title: "أصول الفقه", author: create(:author, name: "الإمام الشافعي"), category: create(:category, name: "أصول الفقه"))
    Book.index_documents([ book ], true)
    Author.index_documents([ book.author ], true)
    Category.index_documents([ book.category ], true)

    assert_equal [ book.id ], mcp_data("list_books", q: "أصول").fetch("books").pluck("id")
    assert_equal [ book.author_id ], mcp_data("list_authors", q: "الشافعي").fetch("authors").pluck("id")
    assert_equal [ book.category_id ], mcp_data("list_categories", q: "أصول").fetch("categories").pluck("id")
    assert_empty mcp_data("search", q: "لاوجودلهذاالمصطلح").fetch("results")
  end

  test "filters stale hidden and deleted search documents" do
    visible = create(:page, content: "الطهارة")
    hidden_book = create(:page, content: "الطهارة")
    hidden_author = create(:page, content: "الطهارة")
    deleted = create(:page, content: "الطهارة")
    Page.index_documents([ visible, hidden_book, hidden_author, deleted ], true)
    hidden_book.file.book.update!(hidden: true)
    hidden_author.file.book.author.update!(hidden: true)
    deleted.destroy!

    assert_equal [ visible.id ], mcp_data("search", q: "الطهارة").fetch("results").pluck("id")
  end

  test "uses current source text when indexed offsets are stale" do
    page = create(:page, content: ("مقدمة " * 300) + "الحج")
    page.update!(content: "نص مصحح")
    index = mock("index")
    index.expects(:search).returns(
      { "hits" => [ { "id" => page.id, "_matchesPosition" => { "content" => [ { "start" => 1_800, "length" => 4 } ] } } ], "totalPages" => 1 }
    )
    Page.stubs(:ms_index).returns(index)

    hit = mcp_data("search", q: "الحج").fetch("results").sole
    assert_equal "نص مصحح", hit.fetch("excerpt")
    assert_equal 0, hit.fetch("excerpt_offset")
  end

  test "reports backend failures without exposing connection details" do
    Page.stubs(:ms_index).raises(StandardError, "secret search key")
    Rails.error.stubs(:report)

    result = mcp_call("search", q: "الفقه")
    assert_equal true, result.fetch("isError")
    assert_equal "internal_error", result.dig("structuredContent", "error", "code")
    refute_includes result.to_json, "secret search key"
  end

  test "bounds an excerpt when the index has no match positions" do
    page = create(:page, content: "النص الأصلي")
    index = mock("index")
    index.expects(:search).returns({ "hits" => [ { "id" => page.id } ], "totalPages" => 1 })
    Page.stubs(:ms_index).returns(index)

    hit = mcp_data("search", q: "النص").fetch("results").sole
    assert_equal page.content, hit.fetch("excerpt")
    assert_equal 0, hit.fetch("excerpt_offset")
    assert_equal false, hit.fetch("excerpt_truncated")
  end
end
