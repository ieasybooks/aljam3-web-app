require "rails_helper"

RSpec.describe "Categories" do
  let(:category) { create(:category) }

  describe "GET /categories" do
    it "returns http success" do
      get categories_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/:id" do
    context "with search functionality" do
      let!(:book) { create(:book, category: category, title: "Ruby Programming", hidden: false) }
      let!(:hidden_book) { create(:book, category: category, title: "Hidden Book", hidden: true) } # rubocop:disable RSpec/LetSetup

      context "with query parameter" do
        let(:mock_pagy) do
          double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 2) } # rubocop:disable RSpec/VerifiedDoubles
        end

        let(:mock_search_results) do
          double("search_results").tap do |results| # rubocop:disable RSpec/VerifiedDoubles
            allow(results).to receive_messages(
              any?: true,
              size: 2
            )

            allow(results).to receive(:each_with_index) do |&block|
              [ book ].each_with_index(&block)
            end
          end
        end

        before do
          allow(Book).to receive(:pagy_search).and_return(mock_search_results)
          allow_any_instance_of(CategoriesController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "searches books using Meilisearch with category filter" do
            get category_path(id: category.id, q: "ruby"), as: :html

            expect(Book).to have_received(:pagy_search).with(
              "ruby",
              filter: %((hidden = false OR hidden NOT EXISTS) AND category = "#{category.id}"),
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the category show view with search results" do # rubocop:disable RSpec/MultipleExpectations
            get category_path(id: category.id, q: "ruby"), as: :html

            expect(response.body).to include("Ruby Programming")
            expect(response.body).not_to include("Hidden Book")
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "searches books using Meilisearch with category filter" do
            get category_path(id: category.id, q: "rails"), as: :turbo_stream

            expect(Book).to have_received(:pagy_search).with(
              "rails",
              filter: %((hidden = false OR hidden NOT EXISTS) AND category = "#{category.id}"),
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the category books list with search results" do # rubocop:disable RSpec/MultipleExpectations
            get category_path(id: category.id, q: "rails"), as: :turbo_stream

            expect(response.body).to include("Ruby Programming")
            expect(response.body).not_to include("Hidden Book")
          end
        end

        context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
          let(:controller) { CategoriesController.new }

          before do
            allow(CategoriesController).to receive(:new).and_return(controller)
            allow(controller).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ])
          end

          it "uses default limit of 20 when no limit specified" do
            get category_path(id: category.id, q: "ruby"), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 20
            )
          end

          it "uses custom limit when specified" do
            get category_path(id: category.id, q: "ruby", limit: 50), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 50
            )
          end

          it "caps limit at 1000 when higher value is provided" do
            get category_path(id: category.id, q: "ruby", limit: 1500), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 1000
            )
          end

          it "uses limit 0 when invalid limit is provided" do
            get category_path(id: category.id, q: "ruby", limit: "invalid"), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 0
            )
          end
        end
      end

      context "without query parameter" do
        let(:mock_pagy) do
          double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 2) } # rubocop:disable RSpec/VerifiedDoubles
        end

        let(:mock_books_relation) do
          double("books_relation").tap do |relation| # rubocop:disable RSpec/VerifiedDoubles
            allow(relation).to receive_messages(
              any?: true,
              size: 2
            )

            allow(relation).to receive(:each_with_index) do |&block|
              [ book ].each_with_index(&block)
            end
          end
        end

        before do
          allow_any_instance_of(CategoriesController).to receive(:pagy).and_return([ mock_pagy, mock_books_relation ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query through category association" do
            allow(category).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
            allow(Category).to receive(:find).with(category.id.to_s).and_return(category)

            get category_path(id: category.id), as: :html

            expect(category).to have_received(:books)
          end

          it "does not call Meilisearch" do
            allow(Book).to receive(:pagy_search)

            get category_path(id: category.id), as: :html

            expect(Book).not_to have_received(:pagy_search)
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query through category association" do
            allow(category).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
            allow(Category).to receive(:find).with(category.id.to_s).and_return(category)

            get category_path(id: category.id), as: :turbo_stream

            expect(category).to have_received(:books)
          end

          it "does not call Meilisearch" do
            allow(Book).to receive(:pagy_search)

            get category_path(id: category.id), as: :turbo_stream

            expect(Book).not_to have_received(:pagy_search)
          end
        end

        context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
          let(:controller) { CategoriesController.new }

          before do
            allow(CategoriesController).to receive(:new).and_return(controller)
            allow(controller).to receive(:pagy).and_return([ mock_pagy, mock_books_relation ])

            allow(category).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
            allow(Category).to receive(:find).with(category.id.to_s).and_return(category)
          end

          it "uses default limit of 20 when no limit specified" do
            get category_path(id: category.id), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 20
            )
          end

          it "uses custom limit when specified" do
            get category_path(id: category.id, limit: 50), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 50
            )
          end

          it "caps limit at 1000 when higher value is provided" do
            get category_path(id: category.id, limit: 1500), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 1000
            )
          end

          it "uses limit 0 when invalid limit is provided" do
            get category_path(id: category.id, limit: "invalid"), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 0
            )
          end
        end
      end
    end

    context "without pagination (page 1)" do
      it "returns http success" do
        get category_path(id: category.id)

        expect(response).to have_http_status(:success)
      end

      it "renders the full view for page 1" do
        get category_path(id: category.id)

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
    end

    context "with pagination (page > 1)" do
      before do
        create_list(:book, 25, category: category)
      end

      it "returns turbo_stream response for page 2" do
        get category_path(id: category.id), params: { page: "2" }, as: :turbo_stream

        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "replaces the correct pagination element for page 2" do
        get category_path(id: category.id), params: { page: "2" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list_2"')
      end
    end
  end
end
