require "swagger_helper"

RSpec.describe "Api::V1::Files" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/books/{book_id}/files" do
    get "List a book's files" do
      tags "Books"
      produces "application/json"

      parameter name: :book_id, in: :path, type: :integer, required: true,
                description: "Book ID"

      response "200", "files found" do
        schema type: :object,
               properties: {
                 files: { type: :array, items: { "$ref" => "#/components/schemas/file" } }
               },
               required: %w[files]

        let(:book_id) { create(:book).id }

        run_test!
      end
    end
  end

  path "/api/v1/books/{book_id}/files/{id}" do
    get "Get a file" do
      tags "Books"
      produces "application/json"

      parameter name: :book_id, in: :path, type: :integer, required: true,
                description: "Book ID"

      parameter name: :id, in: :path, type: :integer, required: true,
                description: "File ID"

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of file's pages to return",
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
          let(:book_id) { create(:book).id }
          let(:id) { create(:book_file, book_id: book_id).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).not_to include("pagination", "pages")
          end
        end

        context "when expand is pages" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book_id) { create(:book).id }
          let(:id) { create(:book_file, book_id: book_id).id }
          let(:"expand[]") { %w[pages] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "pages")
          end
        end

        context "when limit is huge" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book_id) { create(:book).id }
          let(:id) { create(:book_file, book_id: book_id).id }
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

        let(:book_id) { create(:book).id }
        let(:id) { create(:book_file).id }

        run_test!
      end
    end
  end
end
