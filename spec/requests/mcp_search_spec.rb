require "rails_helper"

# rubocop:disable RSpec/ExampleLength -- Exercise complete search-to-source workflows against real indexes.
RSpec.describe "MCP research", :aggregate_failures do
  before do
    host! "aljam3.com"
    https!
    [ Page, Book, Author, Category ].each { |model| model.clear_index!(true) }
  end

  it "finds an Arabic passage beyond the beginning of a long page, then reads it with context" do
    content = ("مقدمة الكتاب " * 200) + "إنما الأعمال بالنيات وإنما لكل امرئ ما نوى" + (" خاتمة " * 200)
    page = create(:page, number: 12, content:)
    create(:page, file: page.file, number: 11, content: "باب النية")
    create(:page, file: page.file, number: 13, content: "شرح الحديث")
    Page.index_documents([ page ], true)

    result = mcp_data("search", q: "الأعمال بالنيات").fetch("results").sole
    expect(result.fetch("excerpt")).to include("إنما الأعمال بالنيات")
    expect(result.fetch("excerpt").length).to be <= 1_000
    expect(result.fetch("excerpt_truncated")).to be(true)
    expect(result.fetch("excerpt")).to eq(content[result.fetch("excerpt_offset"), 1_000])
    expect(result).to include("file_id" => page.book_file_id, "page_number" => 12, "url" => "https://aljam3.com/ar/#{page.file.book_id}/#{page.book_file_id}/12")
    expect(result.fetch("book")).to include("title" => page.file.book.title, "author" => include("name" => page.file.book.author.name), "library" => include("name" => page.file.book.library.name))

    source = mcp_data("get_page", file_id: result.fetch("file_id"), page_number: result.fetch("page_number"))
    expect(source.dig("text", "content")).to eq(content)
    expect(source.fetch("navigation")).to eq("previous_page_number" => 11, "next_page_number" => 13)
  end

  it "combines book, author, category and library filters in text search" do
    book = create(:book)
    matching = create(:page, content: "أحكام الصلاة", file: create(:book_file, book:))
    others = [
      create(:book, author: book.author, category: book.category),
      create(:book, author: book.author, library: book.library),
      create(:book, category: book.category, library: book.library),
      create(:book, author: book.author, category: book.category, library: book.library)
    ].map { |other| create(:page, content: "أحكام الصلاة", file: create(:book_file, book: other)) }
    Page.index_documents([ matching, *others ], true)
    filters = { book_id: book.id, author_id: book.author_id, category_id: book.category_id, library_id: book.library_id }
    expect(mcp_data("search", q: "الصلاة", **filters).fetch("results").pluck("id")).to eq([ matching.id ])
    expect(mcp_data("search", q: "الصلاة", **filters.merge(book_id: others.first.file.book_id)).fetch("results")).to be_empty
  end

  it "paginates search results without repeating hits and handles no matches" do
    pages = create_list(:page, 3, content: "مسائل الزكاة")
    Page.index_documents(pages, true)
    first = mcp_data("search", q: "الزكاة", per_page: 2)
    expect(first.dig("pagination", "next_page")).to eq(2)
    last = mcp_data("search", q: "الزكاة", per_page: 2, page: 2)
    expect(last.dig("pagination", "next_page")).to be_nil
    expect((first.fetch("results") + last.fetch("results")).pluck("id")).to match_array(pages.map(&:id))
    expect(first.dig("results", 0, "excerpt_truncated")).to be(false)
    expect(mcp_data("search", q: "لاوجودلهذاالمصطلح").fetch("results")).to be_empty
  end

  it "searches titles, authors and subjects using the existing indexes" do
    book = create(:book, title: "أصول الفقه", author: create(:author, name: "الإمام الشافعي"), category: create(:category, name: "أصول الفقه"))
    Book.index_documents([ book ], true)
    Author.index_documents([ book.author ], true)
    Category.index_documents([ book.category ], true)
    expect(mcp_data("list_books", q: "أصول", author_id: book.author_id).fetch("books").pluck("id")).to eq([ book.id ])
    expect(mcp_data("list_books", q: "أصول", library_id: book.library_id + 1).fetch("books")).to be_empty
    expect(mcp_data("list_authors", q: "الشافعي").fetch("authors").pluck("id")).to eq([ book.author_id ])
    expect(mcp_data("list_categories", q: "أصول").fetch("categories").pluck("id")).to eq([ book.category_id ])
  end

  it "rechecks database visibility when search documents are stale" do
    visible = create(:page, content: "الطهارة")
    hidden_book = create(:page, content: "الطهارة")
    hidden_author = create(:page, content: "الطهارة")
    deleted = create(:page, content: "الطهارة")
    Page.index_documents([ visible, hidden_book, hidden_author, deleted ], true)
    hidden_book.file.book.update!(hidden: true)
    hidden_author.file.book.author.update!(hidden: true)
    deleted.destroy!
    expect(mcp_data("search", q: "الطهارة").fetch("results").pluck("id")).to eq([ visible.id ])
  end

  it "excludes hidden books and authors from title and author search even before reindexing" do
    book = create(:book, title: "التفسير", author: create(:author, name: "عالم التفسير"))
    Book.index_documents([ book ], true)
    Author.index_documents([ book.author ], true)
    book.author.update!(hidden: true)
    expect(mcp_data("list_books", q: "التفسير").fetch("books")).to be_empty
    expect(mcp_data("list_authors", q: "التفسير").fetch("authors")).to be_empty
  end

  it "reads current source text when the indexed text and offsets are out of date" do
    page = create(:page, content: ("مقدمة " * 300) + "الحج")
    Page.index_documents([ page ], true)
    page.update!(content: "نص مصحح")
    hit = mcp_data("search", q: "الحج").fetch("results").sole
    expect(hit.fetch("excerpt")).to eq("نص مصحح")
    expect(hit.fetch("excerpt_offset")).to eq(0)
  end

  it "reports backend failures as tool errors without returning connection details" do
    allow(Page).to receive(:ms_index).and_raise(StandardError, "secret search key")
    allow(Rails.error).to receive(:report)
    result = mcp_call("search", q: "الفقه")
    expect(result).to include("isError" => true)
    expect(result.dig("structuredContent", "error", "code")).to eq("internal_error")
    expect(result.to_json).not_to include("secret search key")
  end

  it "provides a bounded excerpt when the index supplies no match positions" do
    page = create(:page, content: "النص الأصلي")
    index = instance_double(Meilisearch::Index, search: { "hits" => [ { "id" => page.id } ], "totalPages" => 1 })
    allow(Page).to receive(:ms_index).and_return(index)
    hit = mcp_data("search", q: "النص").fetch("results").sole
    expect(hit).to include("excerpt" => page.content, "excerpt_offset" => 0, "excerpt_truncated" => false)
  end
end
# rubocop:enable RSpec/ExampleLength
