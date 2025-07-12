require "rails_helper"

RSpec.describe "Static" do
  let(:library) { create(:library, :with_books, name: "Library") }

  let(:mock_book) do
    create(:book).tap { allow(it).to receive(:formatted).and_return({ "title" => "<mark>#{it.title}</mark>" }) }
  end

  before do
    books_relation = instance_double(ActiveRecord::Relation)
    ordered_relation = instance_double(ActiveRecord::Relation)
    limited_relation = instance_double(ActiveRecord::Relation)

    allow(Book).to receive(:where).and_return(books_relation)
    allow(books_relation).to receive(:order).and_return(ordered_relation)
    allow(ordered_relation).to receive(:limit).and_return(limited_relation)
    allow(limited_relation).to receive(:pluck).and_return([ mock_book.id ])

    allow(Book).to receive(:where).with(id: [ mock_book.id ]).and_return([ mock_book ])

    libraries_relation = instance_double(ActiveRecord::Relation)

    allow(Library).to receive(:all).and_return(libraries_relation)
    allow(libraries_relation).to receive_messages(
      order: libraries_relation,
      pluck: [
        [ 1, "Main Library" ],
        [ 2, "Branch Library" ],
        [ 3, "Digital Library" ]
      ]
    )

    categories_relation = instance_double(ActiveRecord::Relation)

    allow(Category).to receive(:order).and_return(categories_relation)
    allow(categories_relation).to receive(:pluck).and_return([
      [ 1, "Fiction", 1 ],
      [ 2, "Non-Fiction", 2 ],
      [ 3, "Science", 3 ]
    ])
  end

  describe "GET /" do
    context "when no params are provided" do
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
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
            carousels_books_ids: kind_of(Proc),
            libraries: kind_of(Proc),
            categories: kind_of(Proc)
          )
        end

        it "renders home view for page 1" do
          allow(Views::Static::Home).to receive(:new).and_call_original

          get root_path, params: base_params.merge(page: "1")

          expect(Views::Static::Home).to have_received(:new).with(
            results: mock_search_results,
            pagy: mock_pagy,
            carousels_books_ids: kind_of(Proc),
            libraries: kind_of(Proc),
            categories: kind_of(Proc)
          )
        end
      end

      context "when page is greater than 1" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "renders turbo stream for page 2" do
          allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles

          get root_path, params: base_params.merge(page: "2")

          expect(Components::SearchResultsList).to have_received(:new).with(
            results: mock_search_results,
            pagy: mock_pagy
          )
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
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
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      it "handles unknown search_scope value" do
        get root_path, params: base_params.merge(refinements: { search_scope: "unknown" })

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end
  end
end
