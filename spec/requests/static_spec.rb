require "rails_helper"

RSpec.describe "Static" do
  let(:library) { create(:library, :with_books, name: "Library") }

  let(:mock_book) do
    create(:book).tap { allow(it).to receive(:formatted).and_return({ "title" => "<mark>#{it.title}</mark>" }) }
  end

  let(:mock_page) do
    create(:page).tap { allow(it).to receive(:formatted).and_return({ "content" => "<mark>test content</mark>" }) }
  end

  let(:mock_author) do
    create(:author).tap { allow(it).to receive(:formatted).and_return({ "name" => "<mark>test author</mark>" }) }
  end

  let(:mock_pagy) do
    Pagy.new(count: 100, page: 1)
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
          tabs_search_results: nil,
          search_query_id: nil,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end
    end

    context "when query provided without model (tabs search)" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:params) do
        {
          q: "test query",
          l: "a",
          c: "a",
          a: "a"
        }
      end

      before do
        allow(Page).to receive(:pagy_search).and_return([ mock_page ])
        allow(Book).to receive(:pagy_search).and_return([ mock_book ])
        allow(Author).to receive(:pagy_search).and_return([ mock_author ])

        call_count = 0
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch) do |*args| # rubocop:disable RSpec/AnyInstance
          call_count += 1
          case call_count
          when 1
            [ mock_pagy, [ mock_page ] ]
          when 2
            [ mock_pagy, [ mock_book ] ]
          when 3
            [ mock_pagy, [ mock_author ] ]
          else
            [ mock_pagy, [] ]
          end
        end

        allow(Views::Static::Home).to receive(:new).and_call_original
      end

      it "performs search on all models (Page, Book, Author)" do # rubocop:disable RSpec/MultipleExpectations
        get root_path, params: params

        expect(Page).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
        expect(Author).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders home view with tabs search results" do
        get root_path, params: params

        expect(Views::Static::Home).to have_received(:new).with(
          tabs_search_results: kind_of(TabsSearchResults),
          search_query_id: anything,
          carousels_books_ids: kind_of(Proc),
          libraries: kind_of(Proc),
          categories: kind_of(Proc)
        )
      end

      context "with library filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes library filter in Page and Book search but not Author search" do # rubocop:disable RSpec/MultipleExpectations
          get root_path, params: params.merge(l: library.id.to_s)

          expect(Page).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Book).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{library.id}\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Author).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS)",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end

      context "with category filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes category filter in Page and Book search but not Author search" do # rubocop:disable RSpec/MultipleExpectations
          get root_path, params: params.merge(c: "Fiction")

          expect(Page).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND category = \"Fiction\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Book).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND category = \"Fiction\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Author).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS)",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end

      context "with author filter" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "includes author filter in Page and Book search but not Author search" do # rubocop:disable RSpec/MultipleExpectations
          get root_path, params: params.merge(a: "John Doe")

          expect(Page).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Book).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS) AND author = \"John Doe\"",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
          expect(Author).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS)",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "when model param is 'page' (single model search)" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:params) do
        {
          q: "test query",
          m: "page",
          l: "a",
          c: "a",
          a: "a"
        }
      end

      before do
        allow(Page).to receive(:pagy_search).and_return([ mock_page ])
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [ mock_page ] ]) # rubocop:disable RSpec/AnyInstance
        allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles
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

      it "renders turbo stream with search results list" do
        get root_path, params: params.merge(page: "2")

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: kind_of(SearchResults),
          search_query_id: anything,
          model: "page"
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

    context "when model param is 'book' (single model search)" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:params) do
        {
          q: "test query",
          m: "book",
          l: "a",
          c: "a",
          a: "a"
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return([ mock_book ])
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [ mock_book ] ]) # rubocop:disable RSpec/AnyInstance
        allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles
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

      it "renders turbo stream with search results list" do
        get root_path, params: params.merge(page: "2")

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: kind_of(SearchResults),
          search_query_id: anything,
          model: "book"
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

    context "when model param is 'author' (single model search)" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:params) do
        {
          q: "test query",
          m: "author",
          l: "a",
          c: "a",
          a: "a"
        }
      end

      before do
        allow(Author).to receive(:pagy_search).and_return([ mock_author ])
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [ mock_author ] ]) # rubocop:disable RSpec/AnyInstance
        allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles
      end

      it "performs search on Author model only" do
        get root_path, params: params

        expect(Author).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "renders turbo stream with search results list" do
        get root_path, params: params.merge(page: "2")

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: kind_of(SearchResults),
          search_query_id: anything,
          model: "author"
        )
      end

      context "with filters" do # rubocop:disable RSpec/MultipleMemoizedHelpers
        it "excludes all filters from author search" do
          get root_path, params: params.merge(l: library.id.to_s, c: "Fiction", a: "John Doe")

          expect(Author).to have_received(:pagy_search).with(
            "test query",
            filter: "(hidden = false OR hidden NOT EXISTS)",
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          )
        end
      end
    end

    context "with filter edge cases" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:params) do
        {
          q: "test query",
          m: "book"
        }
      end

      before do
        allow(Book).to receive(:pagy_search).and_return([ mock_book ])
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [ mock_book ] ]) # rubocop:disable RSpec/AnyInstance
        allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles
      end

      it "handles missing refinements gracefully" do # rubocop:disable RSpec/ExampleLength
        allow(Page).to receive(:pagy_search).and_return([ mock_page ])
        allow(Book).to receive(:pagy_search).and_return([ mock_book ])
        allow(Author).to receive(:pagy_search).and_return([ mock_author ])

        call_count = 0
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch) do |*args| # rubocop:disable RSpec/AnyInstance
          call_count += 1
          case call_count
          when 1
            [ mock_pagy, [ mock_page ] ]
          when 2
            [ mock_pagy, [ mock_book ] ]
          when 3
            [ mock_pagy, [ mock_author ] ]
          else
            [ mock_pagy, [] ]
          end
        end

        allow(Components::SearchResultsList).to receive(:new).and_call_original

        get root_path, params: { q: "test query" }

        expect(response).to have_http_status(:success)
      end

      it "handles empty library filter" do
        get root_path, params: params.merge(l: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty category filter" do
        get root_path, params: params.merge(c: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "handles empty author filter" do
        get root_path, params: params.merge(a: "")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores 'a' value for library" do
        get root_path, params: params.merge(l: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores 'a' value for category" do
        get root_path, params: params.merge(c: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "ignores 'a' value for author" do
        get root_path, params: params.merge(a: "a")

        expect(Book).to have_received(:pagy_search).with(
          "test query",
          filter: "(hidden = false OR hidden NOT EXISTS)",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end
    end
  end

  describe "SearchQuery creation" do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:user) { create(:user) }
    let(:params) { { q: "test query", m: "book", l: 1, c: 2, a: 3 } }

    before do
      allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [ mock_book ] ]) # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(StaticController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
      allow(Book).to receive(:pagy_search).and_return([ mock_book ])
      allow(Components::SearchResultsList).to receive(:new).and_return(double(to_s: "component")) # rubocop:disable RSpec/VerifiedDoubles
    end

    context "when conditions are met for SearchQuery creation" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it "creates a SearchQuery with correct attributes" do # rubocop:disable RSpec/MultipleExpectations
        expect { get root_path, params: params }.to change(SearchQuery, :count).by(1)

        search_query = SearchQuery.last
        expect(search_query.query).to eq("test query")
        expect(search_query.refinements).to eq({
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
          "library" => "",
          "author" => "3"
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
        get root_path, params: { q: "test query", m: "book", l: "a", c: "a", a: "a" }

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "library" => "a",
          "category" => "a",
          "author" => "a"
        })
      end

      it "mixes integer and 'select all' values" do
        get root_path, params: { q: "test query", m: "book", l: 1, c: "a", a: 3 }

        search_query = SearchQuery.last
        expect(search_query.refinements).to eq({
          "library" => "1",
          "category" => "a",
          "author" => "3"
        })
      end
    end

    context "when results are blank" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      before do
        allow_any_instance_of(StaticController).to receive(:pagy_meilisearch).and_return([ mock_pagy, [] ]) # rubocop:disable RSpec/AnyInstance
        empty_search_results = instance_double(SearchResults, present?: false, pagy: mock_pagy, results: [])
        allow(SearchResults).to receive(:new).and_return(empty_search_results)
      end

      it "does not create SearchQuery" do
        expect { get root_path, params: params }.not_to change(SearchQuery, :count)
      end

      it "uses params[:qid] as search_query_id" do
        allow(Components::SearchResultsList).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "existing_id")

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: anything,
          search_query_id: "existing_id",
          model: "book"
        )
      end
    end

    context "when qid param is present" do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it "does not create SearchQuery" do
        expect { get root_path, params: params.merge(qid: "existing_id") }.not_to change(SearchQuery, :count)
      end

      it "uses existing qid" do
        allow(Components::SearchResultsList).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "existing_id")

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: anything,
          search_query_id: "existing_id",
          model: "book"
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
        allow(Components::SearchResultsList).to receive(:new).and_call_original

        get root_path, params: params.merge(qid: "prefetch_id"), headers: { "X-Sec-Purpose" => "prefetch" }

        expect(Components::SearchResultsList).to have_received(:new).with(
          search_results: anything,
          search_query_id: "prefetch_id",
          model: "book"
        )
      end
    end
  end

  describe "GET /privacy" do
    it "returns http success" do
      get "/privacy"

      expect(response).to have_http_status(:success)
    end
  end
end
