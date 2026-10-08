module Mcp
  class Server
    TOOLS = [
      BaseTool.build(
        name: "search", title: "Search book passages", reader: Readers::Search, action: :index,
        description: "Search the text of public books for a topic, phrase or quotation. Optional book, author, subject and library filters are combined. Returns short matching excerpts with source metadata and exact page URLs. Read get_page before quoting or interpreting a passage, and follow pagination.next_page to continue; a page can be empty while the search index catches up with hidden or deleted records.",
        schema: ToolSchema.collection(ToolSchema::BOOK_FILTERS.merge(q: ToolSchema::QUERY, book_id: ToolSchema::ID), required: [ :q ])
      ),
      BaseTool.build(
        name: "list_books", title: "Find books", reader: Readers::Catalog, action: :books,
        description: "Browse public books or search their titles using q. Filter by author, subject or source library. Returns bibliographic metadata and book URLs. Use search to search inside books; use get_book for files and downloads.",
        schema: ToolSchema.collection(ToolSchema::BOOK_FILTERS.merge(q: ToolSchema::QUERY))
      ),
      BaseTool.build(
        name: "get_book", title: "Get a book and its files", reader: Readers::Catalog, action: :book,
        description: "Get a public book's title, author, subject and library, plus a paginated list of files in reading order with PDF/TXT/DOCX downloads and first page numbers. Follow pagination.next_page for more files. A file name is supplied as stored; do not infer a printed volume number from its ID or position.",
        schema: ToolSchema.collection({ id: ToolSchema::ID }, required: [ :id ])
      ),
      BaseTool.build(
        name: "get_page", title: "Read a source page", reader: Readers::Pages, action: :show,
        description: "Read the original stored text of an exact page in a book file. Supply file_id and page_number from search or get_book. Includes full citation metadata, a PDF page link and adjacent page numbers for context. Long text is chunked: repeat with text.next_offset until null. Offsets count Unicode characters, not bytes. If text.total_chars is zero, no extracted text is available; consult the PDF.",
        schema: ToolSchema.build({
          file_id: ToolSchema::ID,
          page_number: { type: "integer", minimum: 1, maximum: 2_147_483_647 },
          offset: { type: "integer", minimum: 0, maximum: 2_147_483_647, default: 0 },
          max_chars: { type: "integer", minimum: 1, maximum: 12_000, default: 6_000 }
        }, required: %i[file_id page_number])
      ),
      BaseTool.build(
        name: "list_authors", title: "Find authors", reader: Readers::Catalog, action: :authors,
        description: "Browse or search public authors by name. Returns IDs, names and Aljam3 URLs. Pass an author_id to list_books or search to study that author's works.",
        schema: ToolSchema.collection({ q: ToolSchema::QUERY })
      ),
      BaseTool.build(
        name: "list_categories", title: "Find subjects", reader: Readers::Catalog, action: :categories,
        description: "Browse or search subject names such as fiqh, hadith and Quranic sciences. Pass a category_id to list_books or search to narrow a research topic.",
        schema: ToolSchema.collection({ q: ToolSchema::QUERY })
      ),
      BaseTool.build(
        name: "list_libraries", title: "List source libraries", reader: Readers::Catalog, action: :libraries,
        description: "List source collections and their IDs. Pass library_id to list_books or search to restrict research to one collection. The same work can have different files in different collections.",
        schema: ToolSchema.collection
      )
    ].freeze

    def self.build(url_base:)
      MCP::Server.new(
        name: "aljam3", tools: TOOLS, server_context: { url_base: },
        instructions: "Aljam3 is a library for Sharia study. Find books and passages, read the surrounding pages, and cite the returned sources. Distinguish the author's words from your explanation. Search excerpts are discovery aids, not complete evidence. Do not invent edition details, printed page numbers, hadith grades, or scholarly consensus that the returned sources do not establish."
      )
    end
  end
end
