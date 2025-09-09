require "swagger_helper"

RSpec.describe "Api::V1::Authors" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/authors" do
    get "List authors" do
      tags "Authors"
      produces "application/json"
      description "Returns a paginated list of authors available in the database ordered by name"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query to search authors by name"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of authors to return (default: 20, maximum: 1000)",
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

      response "200", "authors found" do
        schema type: :object,
               properties: {
                 pagination: { "$ref" => "#/components/schemas/pagination" },
                 authors: { type: :array, items: { "$ref" => "#/components/schemas/author" } }
               },
               required: %w[pagination authors]

        let(:q) { "ruby" }
        let(:page) { 1 }

        run_test!
      end
    end
  end

  path "/api/v1/authors/{id}" do
    get "Get an author" do
      tags "Authors"
      produces "application/json"
      description "Returns an author by ID, with an optional paginated list of books by that author"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "Author ID"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query to search books by title"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of author's books to return (default: 20, maximum: 1000)",
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

      parameter name: "expand[]", in: :query, required: false, style: :form, explode: true,
                description: "What resources to expand in the response (default: none)",
                schema: {
                  type: :array,
                  items: {
                    type: :string,
                    enum: %w[books]
                  }
                }

      response "200", "author found" do
        schema allOf: [
                 { "$ref" => "#/components/schemas/author" },
                 {
                   type: :object,
                   properties: {
                     pagination: { "$ref" => "#/components/schemas/pagination" },
                     books: {
                       type: :array,
                       items: {
                         allOf: [
                           { "$ref" => "#/components/schemas/book" },
                           {
                             type: :object,
                             properties: {
                               library: { "$ref" => "#/components/schemas/library" },
                               category: { "$ref" => "#/components/schemas/category" }
                             }
                           }
                         ]
                       }
                     }
                   }
                 }
               ]

        context "when expand is empty" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:author).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).not_to include("pagination", "books")
          end
        end

        context "when expand is books" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:author).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "books")
          end
        end

        context "when limit is huge" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:author).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName
          let(:limit) { 1500 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['pagination']['limit']).to eq(1000)
          end
        end
      end

      response "404", "author not found" do
        schema "$ref" => "#/components/schemas/not_found"

        let(:id) { create(:author, hidden: true).id }

        run_test!
      end
    end
  end
end
