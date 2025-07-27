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
          search_query_id: nil,
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
          q: "test query",
          s: "b",
          l: "a",
          c: "a",
          a: "a"
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
              filter: "(hidden = false OR hidden NOT EXISTS)",
              attributes_to_highlight: %i[title],
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            },
            Page => {
              q: "test query",
              filter: "(hidden = false OR hidden NOT EXISTS)",
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
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      context "with library filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes library filter in search" do
          get root_path, params: params.merge(l: library.id.to_s)

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\"",
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
          get root_path, params: params.merge(c: "Fiction")

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND category = \"Fiction\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND category = \"Fiction\"",
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
          get root_path, params: params.merge(a: "John Doe")

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND author = \"John Doe\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND author = \"John Doe\"",
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
          get root_path, params: params.merge(l: library.id.to_s, c: "Fiction")

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\"",
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
          get root_path, params: params.merge(l: library.id.to_s, c: "Fiction", a: "John Doe")

          expect(Meilisearch::Rails).to have_received(:federated_search).with(
            queries: {
              Book => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
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
                filter: "(hidden = false OR hidden NOT EXISTS)",
                attributes_to_highlight: %i[title],
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              },
              Page => {
                q: "test query",
                filter: "(hidden = false OR hidden NOT EXISTS)",
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
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
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
          q: "test query",
          s: "t",
          l: "a",
          c: "a",
          a: "a"
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
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders home view with paginated results and carousel books" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      context "with filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes filters in book search" do
          get root_path, params: params.merge(l: library.id.to_s, c: "Fiction", a: "John Doe")

          expect(Book).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "when search_scope is content" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
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
          q: "test query",
          s: "c",
          l: "a",
          c: "a",
          a: "a"
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
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders home view with paginated results and carousel books" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      context "with filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes filters in page search" do
          get root_path, params: params.merge(l: library.id.to_s, c: "Fiction", a: "John Doe")

          expect(Page).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\" AND category = \"Fiction\" AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "with pagination" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
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
          q: "test query",
          s: "t",
          l: "a",
          c: "a",
          a: "a"
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
            search_query_id: anything,
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
            search_query_id: anything,
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
            pagy: mock_pagy,
            search_query_id: anything
          )
        end
      end
    end

    context "with filter edge cases" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
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
          q: "test query",
          s: "t"
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      end

      it "handles missing refinements gracefully" do
        allow(Views::Static::Home).to receive(:new).and_call_original

        get root_path, params: { q: "test query" }

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      it "handles empty library filter" do
        get root_path, params: params.merge(s: "t", l: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty category filter" do
        get root_path, params: params.merge(s: "t", c: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty author filter" do
        get root_path, params: params.merge(s: "t", a: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores a value for library" do
        get root_path, params: params.merge(s: "t", l: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores a value for category" do
        get root_path, params: params.merge(s: "t", c: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores a value for author" do
        get root_path, params: params.merge(s: "t", a: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end
    end

    context "with search scope edge cases" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:base_params) { { q: "test query" } }

      before do
        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "handles missing search_scope (defaults to nil case)" do
        get root_path, params: base_params

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      it "handles unknown search_scope value" do
        get root_path, params: base_params.merge(s: "unknown")

        expect(Views::Static::Home).to have_received(:new).with(
          results: nil,
          pagy: nil,
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end
  end

  describe "SearchQuery creation" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:user) { create(:user) }
    let(:params) { { q: "test query", s: "t", l: 1, c: 2, a: 3 } }

    let(:mock_pagy) do
      double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
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

    before do
      allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(StaticController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance

      allow(Book).to receive(:pagy_search).and_return(mock_search_results)
    end

    context "when conditions are met for SearchQuery creation" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it "creates a SearchQuery with correct attributes" do # rubocop:disable RSpec/MultipleExpectations
        expect { get root_path, params: params }.to change(SearchQuery, :count).by(1)

        search_query = SearchQuery.last
        expect(search_query.query).to eq("test query")
        expect(search_query.refinements).to eq({
          "search_scope" => "t",
          "library" => "1",
          "category" => "2",
          "author" => "3"
        })
        expect(search_query.user).to eq(user)
      end

      it "stores the search query and refinements with compacted values (removes nil, keeps empty strings)" do
        get root_path, params: params.merge(l: "", c: nil)

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "search_scope" => "t",
          "library" => "",
          "author" => "3"
        })
      end

      it "removes nil values from refinements" do
        get root_path, params: { q: "test query", s: "t", l: nil, c: nil, a: nil }

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "search_scope" => "t"
        })
      end

      it "associates with current user when present" do
        get root_path, params: params

        search_query = SearchQuery.last
        expect(search_query.user).to eq(user)
      end

      it "works with nil user" do # rubocop:disable RSpec/MultipleExpectations
        allow_any_instance_of(StaticController).to receive(:current_user).and_return(nil) # rubocop:disable RSpec/AnyInstance

        expect { get root_path, params: params }.to change(SearchQuery, :count).by(1)

        search_query = SearchQuery.last
        expect(search_query.user).to be_nil
      end

      it "handles 'select all' refinement values" do
        get root_path, params: { q: "test query", s: "t", l: "a", c: "a", a: "a" }

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "search_scope" => "t",
          "library" => "a",
          "category" => "a",
          "author" => "a"
        })
      end

      it "mixes integer and 'select all' values" do
        get root_path, params: { q: "test query", s: "t", l: 1, c: "a", a: 3 }

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "search_scope" => "t",
          "library" => "1",
          "category" => "a",
          "author" => "3"
        })
      end
    end

    context "when results are blank" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      before do
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        allow(mock_search_results).to receive_messages(any?: false, present?: false)
      end

      it "does not create SearchQuery" do
        expect { get root_path, params: params }.not_to change(SearchQuery, :count)
      end

      it "uses params[:qid] as search_query_id" do
        allow(Views::Static::Home).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "existing_id")

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          search_query_id: "existing_id",
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end

    context "when qid param is present" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it "does not create SearchQuery" do
        expect { get root_path, params: params.merge(qid: "existing_id") }.not_to change(SearchQuery, :count)
      end

      it "uses existing qid" do
        allow(Views::Static::Home).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "existing_id")

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          search_query_id: "existing_id",
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end

    context "when request is a prefetch" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it "does not create SearchQuery" do
        expect {
          get root_path, params: params, headers: { "X-Sec-Purpose" => "prefetch" }
        }.not_to change(SearchQuery, :count)
      end

      it "uses params[:qid] as search_query_id" do
        allow(Views::Static::Home).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "prefetch_id"), headers: { "X-Sec-Purpose" => "prefetch" }

        expect(Views::Static::Home).to have_received(:new).with(
          results: mock_search_results,
          pagy: mock_pagy,
          search_query_id: "prefetch_id",
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end
  end
end
