require "swagger_helper"

RSpec.describe "Api::V1::Libraries" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/libraries" do
    get "List libraries" do
      tags "Libraries"
      produces "application/json"

      response "200", "libraries found" do
        schema type: :object,
               properties: {
                 libraries: { type: :array, items: { "$ref" => "#/components/schemas/library" } }
               },
               required: %w[libraries]

        run_test!
      end
    end
  end

  path "/api/v1/libraries/{id}" do
    get "Get a library" do
      tags "Libraries"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "Library ID"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of library's books to return",
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

      parameter name: "expand[]", in: :query, required: false, style: :form, explode: true,
                description: "What resources to expand in the response",
                schema: {
                  type: :array,
                  items: {
                    type: :string,
                    enum: %w[books]
                  }
                }

      response "200", "library found" do
        schema allOf: [
                 { "$ref" => "#/components/schemas/library" },
                 {
                   type: :object,
                   properties: {
                     pagination: { "$ref" => "#/components/schemas/pagination" },
                     books: { type: :array, items: { "$ref" => "#/components/schemas/book" } }
                   }
                 }
               ]

        context "when expand is empty" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:library).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).not_to include("pagination", "books")
          end
        end

        context "when expand is books" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:library, :with_books).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "books")
          end
        end

        context "when expand is books with search query" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:library) { create(:library) }
          let(:id) { library.id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName
          let(:q) { "ruby" }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "books")
          end
        end

        context "when limit is huge" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:library, :with_books).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName
          let(:limit) { 1500 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['pagination']['limit']).to eq(1000)
          end
        end

        context "when limit is huge and expand is books with search query" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:library, :with_books).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName
          let(:limit) { 1500 }
          let(:q) { "ruby" }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['pagination']['limit']).to eq(1000)
          end
        end
      end

      response "404", "library not found" do
        schema "$ref" => "#/components/schemas/not_found"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
