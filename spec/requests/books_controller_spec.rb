require "swagger_helper"

RSpec.describe BooksController do # rubocop:disable RSpec/EmptyExampleGroup
  path "/books.json" do
    get "get books" do
      tags "Books"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of books to return",
                schema: {
                  type: :integer,
                  default: 20,
                  minimum: 1,
                  maximum: 1000
                }

      parameter name: :page, in: :query, required: false,
                description: "Page number to be returned",
                schema: {
                  type: :integer,
                  default: 1,
                  minimum: 1
                }

      response "200", "books found" do
        schema type: :object,
               properties: {
                 pagination: { "$ref" => "#/components/schemas/pagination" },
                 books: { type: :array, items: { "$ref" => "#/components/schemas/book" } }
               },
               required: %w[pagination books]

        let(:q) { "ruby" }
        let(:page) { 1 }

        run_test!
      end
    end
  end
end
