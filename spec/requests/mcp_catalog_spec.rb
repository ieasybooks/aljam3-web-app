require "rails_helper"

# rubocop:disable RSpec/ExampleLength -- Keep source-reading scenarios and their fixtures together.
RSpec.describe "MCP catalog", :aggregate_failures do
  before do
    host! "aljam3.com"
    https!
  end

  it "combines catalog filters and excludes hidden books and authors" do
    book = create(:book)
    create(:book, author: book.author, category: book.category)
    create(:book, author: book.author, library: book.library)
    create(:book, category: book.category, library: book.library)
    create(:book, author: book.author, category: book.category, library: book.library, hidden: true)
    create(:book, author: create(:author, hidden: true))
    data = mcp_data("list_books", author_id: book.author_id, category_id: book.category_id, library_id: book.library_id)
    expect(data.fetch("books").pluck("id")).to eq([ book.id ])
    expect(data.dig("books", 0, "author")).to include("id" => book.author_id, "name" => book.author.name)
    expect(mcp_data("list_books").fetch("books").size).to eq(4)
  end

  it "paginates books deterministically and serializes identical structured and text content" do
    books = create_list(:book, 3, title: "الفقه")
    result = mcp_call("list_books", per_page: 2)
    expect(JSON.parse(result.dig("content", 0, "text"))).to eq(result.fetch("structuredContent"))
    expect(result.dig("structuredContent", "books").pluck("id")).to eq(books.first(2).map(&:id))
    expect(result.dig("structuredContent", "pagination")).to include("page" => 1, "per_page" => 2, "next_page" => 2)
    last = mcp_data("list_books", per_page: 2, page: 2)
    expect(last.fetch("books").pluck("id")).to eq([ books.last.id ])
    expect(last.dig("pagination", "next_page")).to be_nil
  end

  it "returns book metadata and files in stable reading order with first page numbers" do
    book = create(:book, volumes: -1)
    first = create(:book_file, book:)
    second = create(:book_file, book:)
    create(:page, file: first, number: 7)
    create(:page, file: first, number: 3)
    data = mcp_data("get_book", id: book.id, per_page: 1, locale: "en")
    expect(data.fetch("book")).to include("title" => book.title, "volumes" => nil, "files_count" => 2, "url" => "https://aljam3.com/en/#{book.id}")
    expect(data.fetch("files").first).to include("id" => first.id, "first_page_number" => 3, "download_urls" => { "pdf" => first.pdf_url, "txt" => first.txt_url, "docx" => first.docx_url })
    expect(data.dig("pagination", "next_page")).to eq(2)
    data = mcp_data("get_book", id: book.id, per_page: 1, page: 2)
    expect(data.fetch("files").first).to include("id" => second.id, "first_page_number" => nil)
    expect(data.dig("pagination", "next_page")).to be_nil
  end

  it "makes the collection limit explicit so assistants can narrow their request" do
    create_list(:author, 101)
    data = mcp_data("list_authors", page: 100, per_page: 1)
    expect(data.fetch("authors").size).to eq(1)
    expect(data.fetch("pagination")).to include("next_page" => nil, "limit_reached" => true)
  end

  it "handles books with no files and reports a known volume count" do
    book = create(:book, volumes: 2)
    data = mcp_data("get_book", id: book.id)
    expect(data.dig("book", "volumes")).to eq(2)
    expect(data.fetch("files")).to be_empty
  end

  it "lists authors, subjects and libraries with IDs usable as filters" do
    book = create(:book)
    create(:author, hidden: true)
    expect(mcp_data("list_authors").fetch("authors")).to contain_exactly(include("id" => book.author_id, "url" => "https://aljam3.com/ar/authors/#{book.author_id}"))
    expect(mcp_data("list_categories").fetch("categories")).to contain_exactly(include("id" => book.category_id, "name" => book.category.name))
    expect(mcp_data("list_libraries").fetch("libraries")).to include("id" => book.library_id, "name" => book.library.name)
  end

  it "returns the same not_found error for missing and hidden resources" do
    hidden = create(:book, hidden: true)
    hidden_author_book = create(:book, author: create(:author, hidden: true))
    [ hidden, hidden_author_book ].each do |book|
      file = create(:book_file, book:)
      create(:page, file:, number: 1)
      expect(mcp_call("get_book", id: book.id)).to include("isError" => true)
      expect(mcp_data("get_page", file_id: file.id, page_number: 1).dig("error", "code")).to eq("not_found")
    end
    expect(mcp_data("get_book", id: 9_223_372_036_854_775_807).dig("error", "code")).to eq("not_found")
  end

  it "reads exact Arabic text in character chunks and navigates actual neighboring pages" do
    file = create(:book_file)
    create(:page, file:, number: 2)
    page = create(:page, file:, number: 5, content: "إنما الأعمال بالنيات\nوإنما لكل امرئ ما نوى")
    create(:page, file:, number: 9)
    data = mcp_data("get_page", file_id: file.id, page_number: 5, max_chars: 10, locale: "ur")
    expect(data.fetch("text")).to include("content" => page.content.first(10), "offset" => 0, "total_chars" => page.content.length, "next_offset" => 10)
    expect(data.fetch("navigation")).to eq("previous_page_number" => 2, "next_page_number" => 9)
    expect(data.fetch("page")).to include("page_number" => 5, "file_name" => file.name, "url" => "https://aljam3.com/ur/#{file.book_id}/#{file.id}/5", "pdf_url" => "#{file.pdf_url}#page=5")
    remaining = mcp_data("get_page", file_id: file.id, page_number: 5, offset: 10)
    expect(remaining.dig("text", "content")).to eq(page.content[10..])
    expect(remaining.dig("text", "next_offset")).to be_nil
  end

  it "returns missing pages as errors instead of substituting another page" do
    page = create(:page, number: 1)
    expect(mcp_data("get_page", file_id: page.book_file_id, page_number: 2).dig("error", "code")).to eq("not_found")
    data = mcp_data("get_page", file_id: page.book_file_id, page_number: 1)
    expect(data.fetch("navigation")).to eq("previous_page_number" => nil, "next_page_number" => nil)
  end

  it "bounds very long pages without losing their continuation" do
    page = create(:page, number: 1, content: "أ" * 12_001)
    data = mcp_data("get_page", file_id: page.book_file_id, page_number: 1, max_chars: 12_000)
    expect(data.dig("text", "content").length).to eq(12_000)
    expect(data.dig("text", "next_offset")).to eq(12_000)
    data = mcp_data("get_page", file_id: page.book_file_id, page_number: 1, offset: 12_000)
    expect(data.fetch("text")).to include("content" => "أ", "next_offset" => nil)
  end

  it "preserves a page with no extracted text and rejects offsets beyond the text" do
    page = create(:page, number: 1)
    page.update_columns(content: "")
    data = mcp_data("get_page", file_id: page.book_file_id, page_number: 1)
    expect(data.fetch("text")).to include("content" => "", "total_chars" => 0, "next_offset" => nil)
    expect(data.dig("page", "pdf_url")).to end_with("#page=1")
    expect(mcp_data("get_page", file_id: page.book_file_id, page_number: 1, offset: 1).dig("error", "code")).to eq("invalid_parameter")
  end

  it "does not increment book views or create search analytics" do
    page = create(:page, number: 1)
    expect { mcp_call("get_page", file_id: page.book_file_id, page_number: 1) }.not_to change { [ page.file.book.reload.views_count, SearchQuery.count, SearchClick.count ] }
  end

  it "restores the locale and reports unexpected errors without leaking details" do
    allow(PublicCatalog).to receive(:books).and_raise(StandardError, "private connection details")
    allow(Rails.error).to receive(:report)
    original_locale = I18n.locale
    result = mcp_call("list_books", locale: "en")
    expect(result).to include("isError" => true)
    expect(result.dig("structuredContent", "error", "code")).to eq("internal_error")
    expect(result.to_json).not_to include("private connection details")
    expect(Rails.error).to have_received(:report).with(instance_of(StandardError), handled: true, severity: :error)
    expect(I18n.locale).to eq(original_locale)
  end
end
# rubocop:enable RSpec/ExampleLength
