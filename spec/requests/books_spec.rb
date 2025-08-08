require "rails_helper"

RSpec.describe "Books" do
  let(:user) { create(:user) }

  describe "GET /books" do
    context "with search functionality" do
      let!(:ruby_book) { create(:book, title: "Ruby Programming", hidden: false) }
      let!(:hidden_book) { create(:book, title: "Hidden Ruby Book", hidden: true) } # rubocop:disable RSpec/LetSetup

      context "with query parameter" do
        let(:mock_pagy) do
          double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 1) } # rubocop:disable RSpec/VerifiedDoubles
        end

        let(:mock_search_results) do
          double("search_results").tap do |results| # rubocop:disable RSpec/VerifiedDoubles
            allow(results).to receive_messages(
              any?: true,
              size: 1
            )

            allow(results).to receive(:each_with_index) do |&block|
              [ ruby_book ].each_with_index(&block)
            end
          end
        end

        before do
          allow(Book).to receive(:pagy_search).and_return(mock_search_results)
          allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "searches books using Meilisearch" do
            get books_path(q: "ruby"), as: :html

            expect(Book).to have_received(:pagy_search).with(
              "ruby",
              filter: "hidden = false",
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the books list" do # rubocop:disable RSpec/MultipleExpectations
            get books_path(q: "ruby"), as: :html

            expect(response.body).to include("Ruby Programming")
            expect(response.body).not_to include("Hidden Ruby Book")
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "searches books using Meilisearch" do
            get books_path(q: "ruby"), as: :turbo_stream

            expect(Book).to have_received(:pagy_search).with(
              "ruby",
              filter: "hidden = false",
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the books list" do # rubocop:disable RSpec/MultipleExpectations
            get books_path(q: "ruby"), as: :turbo_stream

            expect(response.body).to include("Ruby Programming")
            expect(response.body).not_to include("Hidden Ruby Book")
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
              [ ruby_book ].each_with_index(&block)
            end
          end
        end

        before do
          allow(Book).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) # rubocop:disable RSpec/VerifiedDoubles
          allow_any_instance_of(BooksController).to receive(:pagy).and_return([ mock_pagy, mock_books_relation ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query" do
            get books_path, as: :html

            expect(Book).to have_received(:where).with(hidden: false)
          end

          it "does not call Meilisearch" do
            allow(Book).to receive(:pagy_search)

            get books_path, as: :html

            expect(Book).not_to have_received(:pagy_search)
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query" do
            get books_path, as: :turbo_stream

            expect(Book).to have_received(:where).with(hidden: false)
          end

          it "does not call Meilisearch" do
            allow(Book).to receive(:pagy_search)

            get books_path, as: :turbo_stream

            expect(Book).not_to have_received(:pagy_search)
          end
        end
      end
    end

    context "with hidden books" do
      let!(:hidden_book) { create(:book, hidden: true) }

      it "displays only non-hidden books" do
        create_list(:book, 3, hidden: false)

        get books_path

        expect(response.body).not_to include(hidden_book.title)
      end

      it "orders books by title" do
        # Create books with specific titles to test ordering
        book_a = create(:book, title: "A Book", hidden: false)
        book_z = create(:book, title: "Z Book", hidden: false)

        get books_path

        expect(response.body.index(book_a.title)).to be < response.body.index(book_z.title)
      end
    end

    context "with pagination" do
      before do
        create_list(:book, 25, hidden: false)
      end

      it "handles paginated requests with turbo stream" do
        get books_path(page: 2), as: :turbo_stream

        expect(response.body).to include('target="results_list_2"')
      end

      it "renders regular view for page 1" do
        get books_path(page: 1)

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end

      it "renders regular view when no page parameter" do
        get books_path

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end
    end

    context "with HTML format" do
      it "renders HTML response" do
        get books_path, as: :html

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end

      it "excludes hidden books" do
        create(:book, title: "Hidden Book", hidden: true)

        get books_path, as: :html

        expect(response.body).not_to include("Hidden Book")
      end
    end

    context "with Turbo Stream format" do
      it "renders turbo stream response" do
        get books_path, as: :turbo_stream

        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "excludes hidden books" do
        create(:book, title: "Hidden Book", hidden: true)

        get books_path, as: :turbo_stream

        expect(response.body).not_to include("Hidden Book")
      end

      it "includes correct turbo stream target for first page" do
        get books_path, as: :turbo_stream

        expect(response.body).to include('target="results_list_1"')
      end

      it "includes correct turbo stream target for specific page" do
        create_list(:book, 25)

        get books_path(page: 2), as: :turbo_stream

        expect(response.body).to include('target="results_list_2"')
      end
    end
  end

  describe "GET /show" do
    let(:book) { create(:book, :with_files) }

    context "without search query parameters" do
      it "redirects to the first page" do
        get book_path(book_id: book.id)

        expect(response).to redirect_to(book_file_page_path(book_id: book.id, file_id: book.pages.first.file.id, page_number: book.pages.first.number))
      end

      it "does not create a SearchClick" do
        expect { get book_path(book_id: book.id) }.not_to change(SearchClick, :count)
      end
    end

    context "with search query parameters" do
      let(:search_query) { SearchQuery.create!(query: "test query", refinements: { book: book.id }, user: user) }

      before do
        sign_in user
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
      end

      it "creates a SearchClick when qid is present" do # rubocop:disable RSpec/MultipleExpectations
        expect {
          get book_path(book_id: book.id), params: { qid: search_query.id, i: "3" }
        }.to change(SearchClick, :count).by(1)

        search_click = SearchClick.last
        expect(search_click.search_query_id).to eq(search_query.id)
        expect(search_click.result).to eq(book)
        expect(search_click.index).to eq(3)
      end

      it "defaults index to -1 when i parameter is missing" do # rubocop:disable RSpec/MultipleExpectations
        expect {
          get book_path(book_id: book.id), params: { qid: search_query.id }
        }.to change(SearchClick, :count).by(1)

        search_click = SearchClick.last
        expect(search_click.index).to eq(-1)
      end

      it "does not create SearchClick when request is prefetch" do
        expect {
          get book_path(book_id: book.id),
              params: { qid: search_query.id, i: "3" },
              headers: { "X-Sec-Purpose" => "prefetch" }
        }.not_to change(SearchClick, :count)
      end

      it "does not create SearchClick when qid is blank" do
        expect {
          get book_path(book_id: book.id), params: { qid: "", i: "3" }
        }.not_to change(SearchClick, :count)
      end

      it "redirects to the first page after creating SearchClick" do
        get book_path(book_id: book.id), params: { qid: search_query.id, i: "3" }

        expect(response).to redirect_to(book_file_page_path(book_id: book.id, file_id: book.pages.first.file.id, page_number: book.pages.first.number))
      end
    end
  end

  describe "GET /search" do
    let(:book) { create(:book, :with_files) }

    let(:mock_search_results) do
      double("search_results").tap do |results| # rubocop:disable RSpec/VerifiedDoubles
        allow(results).to receive_messages(
          any?: true,
          each_with_index: book.pages.zip((0...book.pages.size).to_a),
          size: book.pages.size,
          present?: true
        )
      end
    end

    let(:mock_pagy) do
      double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
    end

    before do
      allow(Page).to receive(:pagy_search).and_return(mock_search_results)
      allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      allow(Components::SearchBookResultsList).to receive(:new).and_call_original
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
    end

    context "with valid search query" do
      it "performs search with correct parameters" do
        get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream

        expect(Page).to have_received(:pagy_search).with(
          "test query",
          filter: %(book = "#{book.id}" AND (hidden = false OR hidden NOT EXISTS)),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "returns ok status" do
        get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream

        expect(response).to have_http_status(:ok)
      end

      it "replaces the results_list element for first page" do
        get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list"')
      end

      context "when qid parameter is present" do
        let!(:existing_search_query) { SearchQuery.create!(query: "existing query", refinements: { book: book.id }, user: user) }

        it "uses existing search_query_id" do
          get book_search_path(book_id: book.id), params: { q: "test query", qid: existing_search_query.id }, as: :turbo_stream

          expect(Components::SearchBookResultsList).to have_received(:new).with(
            book: book,
            results: mock_search_results,
            pagy: mock_pagy,
            search_query_id: existing_search_query.id.to_s
          )
        end

        it "does not create a new SearchQuery" do
          expect {
            get book_search_path(book_id: book.id), params: { q: "test query", qid: existing_search_query.id }, as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end
      end

      context "when qid parameter is missing" do
        it "creates a new SearchQuery when results are present" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream
          }.to change(SearchQuery, :count).by(1)

          search_query = SearchQuery.last
          expect(search_query.query).to eq("test query")
          expect(search_query.refinements).to eq({ "book" => book.id })
          expect(search_query.user).to eq(user)
        end

        it "passes the new search_query_id to component" do
          get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream

          search_query = SearchQuery.last
          expect(Components::SearchBookResultsList).to have_received(:new).with(
            book: book,
            results: mock_search_results,
            pagy: mock_pagy,
            search_query_id: search_query.id
          )
        end

        it "does not create SearchQuery when request is prefetch" do
          expect {
            get book_search_path(book_id: book.id),
                params: { q: "test query" },
                headers: { "X-Sec-Purpose" => "prefetch" },
                as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end

        it "passes nil search_query_id to component when prefetch" do
          get book_search_path(book_id: book.id),
              params: { q: "test query" },
              headers: { "X-Sec-Purpose" => "prefetch" },
              as: :turbo_stream

          expect(Components::SearchBookResultsList).to have_received(:new).with(
            book: book,
            results: mock_search_results,
            pagy: mock_pagy,
            search_query_id: nil
          )
        end
      end

      context "when results are empty" do
        let(:empty_results) do
          double("empty_results").tap do |results| # rubocop:disable RSpec/VerifiedDoubles
            allow(results).to receive_messages(
              any?: false,
              each_with_index: [],
              size: 0,
              present?: false
            )
          end
        end

        before do
          allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy, empty_results ]) # rubocop:disable RSpec/AnyInstance
        end

        it "does not create SearchQuery when results are empty" do
          expect {
            get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end

        it "passes nil search_query_id to component" do
          get book_search_path(book_id: book.id), params: { q: "test query" }, as: :turbo_stream

          expect(Components::SearchBookResultsList).to have_received(:new).with(
            book: book,
            results: empty_results,
            pagy: mock_pagy,
            search_query_id: nil
          )
        end
      end
    end

    context "with pagination" do
      let(:mock_pagy_page) do
        double("pagy").tap { allow(it).to receive_messages(page: 2, next: 3, count: 100) } # rubocop:disable RSpec/VerifiedDoubles
      end

      before do
        allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy_page, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      end

      it "replaces the correct pagination element for subsequent pages" do
        get book_search_path(book_id: book.id), params: { q: "test query", page: "2" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list_2"')
      end

      it "creates SearchQuery for pagination requests when qid is missing" do
        expect {
          get book_search_path(book_id: book.id), params: { q: "test query", page: "2" }, as: :turbo_stream
        }.to change(SearchQuery, :count).by(1)
      end
    end
  end
end
