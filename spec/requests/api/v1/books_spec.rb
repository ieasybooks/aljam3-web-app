require "swagger_helper"

RSpec.describe "Api::V1::Books" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/books" do
    get "List books" do
      tags "Books"
      produces "application/json"
      description "Returns a paginated list of books available in the database ordered by title"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query to search books by title"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of books to return (default: 20, maximum: 1000)",
                schema: {
                  type: :integer,
                  default: 20,
                  minimum: 1,
                  maximum: 1000
                }

      parameter name: :page, in: :query, required: false,
                description: "Page number to be returned (default: 1)",
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

  path "/api/v1/books/{id}" do
    get "Get a book" do
      tags "Books"
      produces "application/json"
      description "Returns a book by ID, with an optional list of files by that book"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "Book ID"

      parameter name: "expand[]", in: :query, required: false, style: :form, explode: true,
                description: "What resources to expand in the response (default: none)",
                schema: {
                  type: :array,
                  items: {
                    type: :string,
                    enum: %w[files]
                  }
                }

      response "200", "book found" do
        schema allOf: [
                 { "$ref" => "#/components/schemas/book" },
                 {
                   type: :object,
                   properties: {
                     files: { type: :array, items: { "$ref" => "#/components/schemas/file" } }
                   }
                 }
               ]

        context "when expand is empty" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).not_to include("files")
          end
        end

        context "when expand is files" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book).id }
          let(:"expand[]") { %w[files] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("files")
          end
        end
      end

      response "404", "book not found" do
        schema "$ref" => "#/components/schemas/not_found"

        let(:id) { create(:book, hidden: true).id }

        run_test!
      end
    end
  end
end
