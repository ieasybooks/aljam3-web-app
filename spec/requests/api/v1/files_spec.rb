require "swagger_helper"

RSpec.describe "Api::V1::Files" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/files/{id}" do
    get "Get a file" do
      tags "Files"
      produces "application/json"
      description "Returns a file by ID, with an optional paginated list of pages by that file"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "File ID"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of file's pages to return (default: 20, maximum: 1000)",
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
                    enum: %w[pages]
                  }
                }

      response "200", "file found" do
        schema allOf: [
          { "$ref" => "#/components/schemas/file" },
          {
            type: :object,
            properties: {
              pagination: { "$ref" => "#/components/schemas/pagination" },
              pages: { type: :array, items: { "$ref" => "#/components/schemas/page" } }
            }
          }
        ]

        context "when expand is empty" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book_file).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).not_to include("pagination", "pages")
          end
        end

        context "when expand is pages" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book_file).id }
          let(:"expand[]") { %w[pages] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "pages")
          end
        end

        context "when limit is huge" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book_file).id }
          let(:"expand[]") { %w[pages] } # rubocop:disable RSpec/VariableName
          let(:limit) { 1500 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['pagination']['limit']).to eq(1000)
          end
        end
      end

      response "404", "file not found" do
        schema "$ref" => "#/components/schemas/not_found"

        context "when id does not exist" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { 0 }

          run_test!
        end

        context "when file is hidden" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:id) { create(:book_file, book: create(:book, hidden: true)).id }

          run_test!
        end
      end
    end
  end
end
