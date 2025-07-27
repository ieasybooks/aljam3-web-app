require "rails_helper"

RSpec.describe "Books" do
  let(:user) { create(:user) }

  describe "GET /show" do
    let(:book) { create(:book, :with_files) }

    context "without search query parameters" do
      it "redirects to the first page" do
        get book_path(book.id)

        expect(response).to redirect_to(book_file_page_path(book.id, book.pages.first.file.id, book.pages.first.number))
      end

      it "does not create a SearchClick" do
        expect { get book_path(book.id) }.not_to change(SearchClick, :count)
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
          get book_path(book.id), params: { qid: search_query.id, i: "3" }
        }.to change(SearchClick, :count).by(1)

        search_click = SearchClick.last
        expect(search_click.search_query_id).to eq(search_query.id)
        expect(search_click.result).to eq(book)
        expect(search_click.index).to eq(3)
      end

      it "defaults index to -1 when i parameter is missing" do # rubocop:disable RSpec/MultipleExpectations
        expect {
          get book_path(book.id), params: { qid: search_query.id }
        }.to change(SearchClick, :count).by(1)

        search_click = SearchClick.last
        expect(search_click.index).to eq(-1)
      end

      it "does not create SearchClick when request is prefetch" do
        expect {
          get book_path(book.id),
              params: { qid: search_query.id, i: "3" },
              headers: { "X-Sec-Purpose" => "prefetch" }
        }.not_to change(SearchClick, :count)
      end

      it "does not create SearchClick when qid is blank" do
        expect {
          get book_path(book.id), params: { qid: "", i: "3" }
        }.not_to change(SearchClick, :count)
      end

      it "redirects to the first page after creating SearchClick" do
        get book_path(book.id), params: { qid: search_query.id, i: "3" }

        expect(response).to redirect_to(book_file_page_path(book.id, book.pages.first.file.id, book.pages.first.number))
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
        get book_search_path(book), params: { q: "test query" }, as: :turbo_stream

        expect(Page).to have_received(:pagy_search).with(
          "test query",
          filter: %(book = "#{book.id}" AND (hidden = false OR hidden NOT EXISTS)),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "returns ok status" do
        get book_search_path(book), params: { q: "test query" }, as: :turbo_stream

        expect(response).to have_http_status(:ok)
      end

      it "replaces the results_list element for first page" do
        get book_search_path(book), params: { q: "test query" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list"')
      end

      context "when qid parameter is present" do
        let!(:existing_search_query) { SearchQuery.create!(query: "existing query", refinements: { book: book.id }, user: user) }

        it "uses existing search_query_id" do
          get book_search_path(book), params: { q: "test query", qid: existing_search_query.id }, as: :turbo_stream

          expect(Components::SearchBookResultsList).to have_received(:new).with(
            book: book,
            results: mock_search_results,
            pagy: mock_pagy,
            search_query_id: existing_search_query.id.to_s
          )
        end

        it "does not create a new SearchQuery" do
          expect {
            get book_search_path(book), params: { q: "test query", qid: existing_search_query.id }, as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end
      end

      context "when qid parameter is missing" do
        it "creates a new SearchQuery when results are present" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_search_path(book), params: { q: "test query" }, as: :turbo_stream
          }.to change(SearchQuery, :count).by(1)

          search_query = SearchQuery.last
          expect(search_query.query).to eq("test query")
          expect(search_query.refinements).to eq({ "book" => book.id })
          expect(search_query.user).to eq(user)
        end

        it "passes the new search_query_id to component" do
          get book_search_path(book), params: { q: "test query" }, as: :turbo_stream

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
            get book_search_path(book),
                params: { q: "test query" },
                headers: { "X-Sec-Purpose" => "prefetch" },
                as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end

        it "passes nil search_query_id to component when prefetch" do
          get book_search_path(book),
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
            get book_search_path(book), params: { q: "test query" }, as: :turbo_stream
          }.not_to change(SearchQuery, :count)
        end

        it "passes nil search_query_id to component" do
          get book_search_path(book), params: { q: "test query" }, as: :turbo_stream

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
        get book_search_path(book), params: { q: "test query", page: "2" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list_2"')
      end

      it "creates SearchQuery for pagination requests when qid is missing" do
        expect {
          get book_search_path(book), params: { q: "test query", page: "2" }, as: :turbo_stream
        }.to change(SearchQuery, :count).by(1)
      end
    end
  end
end
