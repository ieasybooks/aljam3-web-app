require "swagger_helper"

RSpec.describe "Api::V1::Pages" do # rubocop:disable RSpec/EmptyExampleGroup
  path "/api/v1/files/{file_id}/pages" do
    get "Get all pages of a file" do
      tags "Files"
      produces "application/json"
      description "Returns all pages of a file"

      parameter name: :file_id, in: :path, type: :integer, required: true,
                description: "File ID"

      response "200", "pages found" do
        schema type: :object,
               properties: {
                 pages: { type: :array, items: { "$ref" => "#/components/schemas/page" } }
               },
               required: %w[pages]

        let(:file_id) { create(:book_file).id }

        run_test!
      end

      response "404", "file not found" do
        schema "$ref" => "#/components/schemas/not_found"

        context "when file_id does not exist" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:file_id) { 0 }

          run_test!
        end

        context "when file is hidden" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:file_id) { create(:book_file, book: create(:book, hidden: true)).id }

          run_test!
        end
      end
    end
  end
end
