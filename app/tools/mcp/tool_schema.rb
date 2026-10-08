module Mcp
  class ToolSchema
    ID = { type: "integer", minimum: 1, maximum: 9_223_372_036_854_775_807 }.freeze
    QUERY = { type: "string", minLength: 1, maxLength: 500, pattern: "\\S", description: "Search terms, usually in Arabic. Use concise terms or a quoted phrase for an exact phrase search." }.freeze
    LOCALE = { type: "string", enum: %w[ar ur en], default: "ar", description: "Language of Aljam3 links; does not translate source text or change search relevance." }.freeze
    PAGINATION = {
      page: { type: "integer", minimum: 1, maximum: 100, default: 1, description: "Result page, not a book's page number." },
      per_page: { type: "integer", minimum: 1, maximum: 20, default: 10 }
    }.freeze
    BOOK_FILTERS = {
      author_id: ID.merge(description: "Restrict to this author; discover IDs with list_authors."),
      category_id: ID.merge(description: "Restrict to this subject; discover IDs with list_categories."),
      library_id: ID.merge(description: "Restrict to this source collection; discover IDs with list_libraries.")
    }.freeze

    def self.collection(properties = {}, required: [])
      build(PAGINATION.merge(properties), required:)
    end

    def self.build(properties, required: [])
      { type: "object", properties: properties.merge(locale: LOCALE), required:, additionalProperties: false }
    end
  end
end
