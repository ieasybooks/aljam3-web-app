require "swagger_helper"

RSpec.describe "Api::V1::Categories" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/categories" do
    get "List categories" do
      tags "Categories"
      produces "application/json"

      response "200", "categories found" do
        schema type: :object,
               properties: {
                 categories: { type: :array, items: { "$ref" => "#/components/schemas/category" } }
               },
               required: %w[categories]

        run_test!
      end
    end
  end

  path "/api/v1/categories/{id}" do
    get "Get a category" do
      tags "Categories"
      produces "application/json"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "Category ID"

      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search query"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of category's books to return",
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

      response "200", "category found" do
        schema allOf: [
                 { "$ref" => "#/components/schemas/category" },
                 {
                   type: :object,
                   properties: {
                     pagination: { "$ref" => "#/components/schemas/pagination" },
                     books: { type: :array, items: { "$ref" => "#/components/schemas/book" } }
                   }
                 }
               ]

        context "when expand is empty" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:category).id }

          run_test!
        end

        context "when expand is books" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:category).id }
          let(:"expand[]") { %w[books] } # rubocop:disable RSpec/VariableName

          run_test!
        end
      end

      response "404", "category not found" do
        schema "$ref" => "#/components/schemas/not_found"

        let(:id) { 0 }

        run_test!
      end
    end
  end
end
