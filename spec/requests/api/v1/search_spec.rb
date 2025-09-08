require "swagger_helper"

RSpec.describe "Api::V1::Search" do
  path "/api/v1/search" do
    get "Search pages across all books" do
      tags "Search"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, required: true,
                description: "Search query"

      parameter name: :library, in: :query, type: :integer, required: false,
                description: "Filter by library ID"

      parameter name: "books[]", in: :query, required: false, style: :form, explode: true,
                description: "Filter by book IDs",
                schema: {
                  type: :array,
                  items: { type: :integer }
                }

      parameter name: "authors[]", in: :query, required: false, style: :form, explode: true,
                description: "Filter by author IDs",
                schema: {
                  type: :array,
                  items: { type: :integer }
                }

      parameter name: "categories[]", in: :query, required: false, style: :form, explode: true,
                description: "Filter by category IDs",
                schema: {
                  type: :array,
                  items: { type: :integer }
                }

      parameter name: :limit, in: :query, required: false,
                description: "Limit the number of pages to return",
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

      response "200", "search results found" do
        schema type: :object,
               properties: {
                 pagination: { "$ref" => "#/components/schemas/pagination" },
                 pages: { type: :array, items: { "$ref" => "#/components/schemas/page" } }
               },
               required: %w[pagination pages]

        context "with basic search query" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book) { create(:book) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Islam is a religion") }
          let(:q) { "Islam" }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data).to include("pagination", "pages")
            expect(data["pages"]).to be_an(Array)
          end
        end

        context "with library filter" do # rubocop:disable RSpec/EmptyExampleGroup,RSpec/MultipleMemoizedHelpers
          let(:test_library) { create(:library) }
          let(:book) { create(:book, library: test_library) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Quran verse") }
          let(:q) { "Quran" }
          let(:library) { create(:library).id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pages"]).to be_an(Array)
          end
        end

        context "with books filter" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book) { create(:book) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Hadith text") }
          let(:q) { "Hadith" }
          let(:"books[]") { [ book.id ] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pages"]).to be_an(Array)
          end
        end

        context "with authors filter" do # rubocop:disable RSpec/EmptyExampleGroup,RSpec/MultipleMemoizedHelpers
          let(:author) { create(:author) }
          let(:book) { create(:book, author: author) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Scholar writing") }
          let(:q) { "Scholar" }
          let(:"authors[]") { [ author.id ] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pages"]).to be_an(Array)
          end
        end

        context "with categories filter" do # rubocop:disable RSpec/EmptyExampleGroup,RSpec/MultipleMemoizedHelpers
          let(:category) { create(:category) }
          let(:book) { create(:book, category: category) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Fiqh ruling") }
          let(:q) { "Fiqh" }
          let(:"categories[]") { [ category.id ] } # rubocop:disable RSpec/VariableName

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pages"]).to be_an(Array)
          end
        end

        context "with limit parameter" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book) { create(:book) }
          let(:book_file) { create(:book_file, book: book) }
          let(:pages) { create_list(:page, 5, file: book_file, content: "Test content") }
          let(:q) { "Test" }
          let(:limit) { 2 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pagination"]["limit"]).to eq(2)
          end
        end

        context "when limit is huge" do # rubocop:disable RSpec/EmptyExampleGroup
          let(:book) { create(:book) }
          let(:book_file) { create(:book_file, book: book) }
          let(:file_page) { create(:page, file: book_file, content: "Large limit test") }
          let(:q) { "Large" }
          let(:limit) { 1500 }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data["pagination"]["limit"]).to eq(1000)
          end
        end
      end
    end
  end
end
