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

        let(:book_file) { create(:book_file) }
        let(:file_id) { book_file.id }
        let!(:file_page) { create(:page, file: book_file, number: 7) }

        run_test! do |response|
          expect(JSON.parse(response.body).fetch("pages")).to contain_exactly(
            include("id" => file_page.id, "file_id" => book_file.id,
                    "number" => 7, "content" => file_page.content)
          )
        end
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
