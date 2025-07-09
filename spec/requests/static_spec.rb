require "rails_helper"

RSpec.describe "Static" do
  let(:library) { create(:library, :with_books, name: "Library") }

  let(:mock_book) do
    create(:book).tap { allow(it).to receive(:formatted).and_return({ "title" => "<mark>#{it.title}</mark>" }) }
  end

  let(:mock_carousels_books_ids) do
    {
      faith:    [ mock_book.id ],
      quran:    [ mock_book.id ],
      hadith:   [ mock_book.id ],
      fiqh:     [ mock_book.id ],
      history:  [ mock_book.id ],
      language: [ mock_book.id ],
      other:    [ mock_book.id ]
    }
  end

  let(:mock_libraries) { [ [ 1, "Main Library" ], [ 2, "Branch Library" ], [ 3, "Digital Library" ] ] }
  let(:mock_categories) { [ [ 1, "Fiction", 1 ], [ 2, "Non-Fiction", 2 ], [ 3, "Science", 3 ] ] }

  before do
    allow(Rails.cache).to receive(:fetch).with("carousels_books_ids", expires_in: 1.hour).and_return(mock_carousels_books_ids)
    allow(Rails.cache).to receive(:fetch).with("categories", expires_in: 1.week).and_return(mock_categories)
    allow(Rails.cache).to receive(:fetch).with("libraries", expires_in: 1.week).and_return(mock_libraries)
    allow(Book).to receive(:where).with(id: [ mock_book.id ]).and_return([ mock_book ])
  end

  describe "GET /" do
    context "when no params are provided" do
      context "with carousel books in cache" do
        it "returns http success" do
          get root_path

          expect(response).to have_http_status(:success)
        end

        it "renders home view" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path

          expect(Views::Static::Home).to have_received(:new).with(
            results: nil,
            pagy: nil,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end
      end

      context "with no carousel books in cache" do
        before do
          allow(Rails.cache).to receive(:fetch).with("carousels_books_ids", expires_in: 1.hour).and_yield.and_return(mock_carousels_books_ids)
          allow(Book).to receive(:where).and_return(Book.none)
          allow(Book).to receive(:order).with("RANDOM()").and_return(double(limit: double(pluck: [ mock_book.id ]))) # rubocop:disable RSpec/VerifiedDoubles
        end

        it "returns http success" do
          get root_path

          expect(response).to have_http_status(:success)
        end

        it "renders home view with random carousel books" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path

          expect(Views::Static::Home).to have_received(:new).with(
            results: nil,
            pagy: nil,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end
      end

      context "with no categories in cache" do
        before do
          allow(Rails.cache).to receive(:fetch).with("categories", expires_in: 1.week).and_yield.and_return(mock_categories)
          allow(Category).to receive_message_chain(:order, :pluck).and_return(mock_categories) # rubocop:disable RSpec/MessageChain
        end

        it "renders home view with fresh categories list" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path

          expect(Views::Static::Home).to have_received(:new).with(
            results: nil,
            pagy: nil,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end
      end

      context "with no libraries in cache" do
        before do
          allow(Rails.cache).to receive(:fetch).with("libraries", expires_in: 1.week).and_yield.and_return(mock_libraries)
          allow(Library).to receive_message_chain(:all, :order, :pluck).and_return(mock_libraries) # rubocop:disable RSpec/MessageChain
        end

        it "renders home view with fresh libraries list" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path

          expect(Views::Static::Home).to have_received(:new).with(
            results: nil,
            pagy: nil,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end
      end
    end

    context "when search_scope is title-and-content" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_federated_results) do
        double("federated_results").tap do # rubocop:disable RSpec/VerifiedDoubles
          allow(it).to receive_messages(
            any?: true,
            each_with_index: [ mock_book, 0 ],
            size: 1,
            metadata: { "estimatedTotalHits" => 100 }
          )
        end
      end

      let(:params) do
        {
          query: "test query",
          refinements: {
            search_scope: "title-and-content",
            library: "all-libraries",
            category: "all-categories"
          }
        }
      end

      before do
        allow(Meilisearch::Rails).to receive(:federated_search).and_return(mock_federated_results)
        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "performs federated search on both Book and Page models" do
        get root_path, params: params

        expect(Meilisearch::Rails).to have_received(:federated_search).with(
          queries: {
            Book => {
              q: "test query",
              filter: nil,
              attributes_to_highlight: %i[title],
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            },
            Page => {
              q: "test query",
              filter: nil,
              attributes_to_highlight: %i[content],
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            }
          },
          federation: { offset: 0 }
        )
      end

      it "renders home view with federated results" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_federated_results,
          pagy: nil,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end

      context "with library filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes library filter in search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(library: library.id.to_s))

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "library = \"#{library.id}\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "library = \"#{library.id}\"",
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 0 }
          )
        end
      end

      context "with category filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes category filter in search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(category: "Fiction"))

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "category = \"Fiction\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "category = \"Fiction\"",
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 0 }
          )
        end
      end

      context "with author filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes author filter in search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(author: "John Doe"))

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "author = \"John Doe\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "author = \"John Doe\"",
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 0 }
          )
        end
      end

      context "with both library and category filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes both filters in search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(library: library.id.to_s, category: "Fiction"))

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "library = \"#{library.id}\" AND category = \"Fiction\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "library = \"#{library.id}\" AND category = \"Fiction\"",
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 0 }
          )
        end
      end

      context "with library, category, and author filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes all filters in search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(library: library.id.to_s, category: "Fiction", author: "John Doe"))

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 0 }
          )
        end
      end

      context "with pagination" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "calculates correct offset for federated search" do
          get root_path, params: params.merge(page: "3")

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: nil,
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: nil,
                attributes_to_highlight: %i[content],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              }
            },
            federation: { offset: 40 }
          )
        end
      end
    end

    context "when search_scope is title" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil) } # rubocop:disable RSpec/VerifiedDoubles
      end

      let(:mock_search_results) do
        double("search_results").tap do # rubocop:disable RSpec/VerifiedDoubles
          allow(it).to receive_messages(
            any?: true,
            each_with_index: [ mock_book, 0 ],
            size: 1,
            respond_to?: false
          )
        end
      end

      let(:params) do
        {
          query: "test query",
          refinements: {
            search_scope: "title",
            library: "all-libraries",
            category: "all-categories"
          }
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "performs search on Book model only" do
        get root_path, params: params

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders home view with paginated results and carousel books" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end

      context "with filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes filters in book search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(library: library.id.to_s, category: "Fiction", author: "John Doe"))

          expect(Book).to have_received(:pagy_search).with(
            "test query",
            filter: "library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "when search_scope is content" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil) } # rubocop:disable RSpec/VerifiedDoubles
      end

      let(:mock_search_results) do
        double("search_results").tap do # rubocop:disable RSpec/VerifiedDoubles
          allow(it).to receive_messages(
            any?: true,
            each_with_index: [ mock_book, 0 ],
            size: 1,
            respond_to?: false
          )
        end
      end

      let(:params) do
        {
          query: "test query",
          refinements: {
            search_scope: "content",
            library: "all-libraries",
            category: "all-categories"
          }
        }
      end

      before do
        allow(Page).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "performs search on Page model only" do
        get root_path, params: params

        expect(Page).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders home view with paginated results and carousel books" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end

      context "with filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes filters in page search" do
          get root_path, params: params.merge(refinements: params[:refinements].merge(library: library.id.to_s, category: "Fiction", author: "John Doe"))

          expect(Page).to have_received(:pagy_search).with(
            "test query",
            filter: "library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "with pagination" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil) } # rubocop:disable RSpec/VerifiedDoubles
      end

      let(:mock_search_results) do
        double("search_results").tap do # rubocop:disable RSpec/VerifiedDoubles
          allow(it).to receive_messages(
            any?: true,
            each_with_index: [ mock_book, 0 ],
            size: 1,
            respond_to?: false
          )
        end
      end

      let(:base_params) do
        {
          query: "test query",
          refinements: {
            search_scope: "title",
            library: "all-libraries",
            category: "all-categories"
          }
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      end

      context "when page is 1 or not provided" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "renders home view when page not provided" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path, params: base_params

          expect(Views::Static::Home).to have_received(:new).with(
            results: mock_search_results,
            pagy: mock_pagy,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end

        it "renders home view for page 1" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path, params: base_params.merge(page: "1")

          expect(Views::Static::Home).to have_received(:new).with(
            results: mock_search_results,
            pagy: mock_pagy,
            carousels_books_ids: mock_carousels_books_ids,
            libraries: mock_libraries,
            categories: mock_categories
          )
        end
      end

      context "when page is greater than 1" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "renders turbo stream for page 2" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
          allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles

          get root_path, params: base_params.merge(page: "2")

          expect(Components::SearchResultsList).to have_received(:new).with(
            results: mock_search_results,
            pagy: mock_pagy
          )

          expect(Rails.cache).not_to have_received(:fetch).with("carousels_books_ids", expires_in: 1.hour)
          expect(Rails.cache).not_to have_received(:fetch).with("categories", expires_in: 1.week)
          expect(Rails.cache).not_to have_received(:fetch).with("libraries", expires_in: 1.week)
        end
      end
    end

    context "with filter edge cases" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil) } # rubocop:disable RSpec/VerifiedDoubles
      end

      let(:mock_search_results) do
        double("search_results").tap do # rubocop:disable RSpec/VerifiedDoubles
          allow(it).to receive_messages(
            any?: true,
            each_with_index: [ mock_book, 0 ],
            size: 1,
            respond_to?: false
          )
        end
      end

      let(:params) do
        {
          query: "test query",
          refinements: {
            search_scope: "title"
          }
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      end

      it "handles missing refinements gracefully" do
        allow(Views::Static::Home).to receive(:new).and_call_original

        get root_path, params: { query: "test query" }

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end

      it "handles empty library filter" do
        get root_path, params: params.merge(refinements: { search_scope: "title", library: "" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty category filter" do
        get root_path, params: params.merge(refinements: { search_scope: "title", category: "" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty author filter" do
        get root_path, params: params.merge(refinements: { search_scope: "title", author: "" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores all-libraries value" do
        get root_path, params: params.merge(refinements: { search_scope: "title", library: "all-libraries" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores all-categories value" do
        get root_path, params: params.merge(refinements: { search_scope: "title", category: "all-categories" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores all-authors value" do
        get root_path, params: params.merge(refinements: { search_scope: "title", author: "all-authors" })

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: nil,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end
    end

    context "with search scope edge cases" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:base_params) { { query: "test query" } }

      before do
        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "handles missing search_scope (defaults to nil case)" do
        get root_path, params: base_params

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end

      it "handles unknown search_scope value" do
        get root_path, params: base_params.merge(refinements: { search_scope: "unknown" })

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          carousels_books_ids: mock_carousels_books_ids,
          libraries: mock_libraries,
          categories: mock_categories
        )
      end
    end
  end
end
