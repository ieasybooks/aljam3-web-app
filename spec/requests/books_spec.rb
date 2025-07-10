require 'rails_helper'

RSpec.describe "Books" do
  describe "GET /show" do
    let(:book) { create(:book, :with_files) }

    it "redirects to the first page" do
      get book_path(book.id)

      expect(response).to redirect_to(book_file_page_path(book.id, book.pages.first.file.id, book.pages.first.number))
    end
  end

  describe "GET /search" do
    let(:book) { create(:book, :with_files) }

    let(:mock_search_results) do
      double("search_results").tap do |results| # rubocop:disable RSpec/VerifiedDoubles
        allow(results).to receive_messages(
          any?: true,
          each_with_index: book.pages.zip((0...book.pages.size).to_a),
          size: book.pages.size
        )
      end
    end

    context "with valid search query" do
      let(:mock_pagy) do
        double("pagy").tap { allow(it).to receive_messages(page: 1, next: nil) } # rubocop:disable RSpec/VerifiedDoubles
      end

      before do
        allow(Page).to receive(:pagy_search).and_return(mock_search_results)
        allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        allow(Components::SearchBookResultsList).to receive(:new).and_call_original
      end

      it "performs search with correct parameters" do
        get book_search_path(book), params: { query: "test query" }, as: :turbo_stream

        expect(Page).to have_received(:pagy_search).with(
          "test query",
          filter: %(book = "#{book.id}"),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        )
      end

      it "returns ok status" do
        get book_search_path(book), params: { query: "test query" }, as: :turbo_stream

        expect(response).to have_http_status(:ok)
      end

      it "replaces the results_list element for first page" do
        get book_search_path(book), params: { query: "test query" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list"')
      end

      it "initializes SearchBookResultsList component with correct parameters" do
        get book_search_path(book), params: { query: "test query" }, as: :turbo_stream

        expect(Components::SearchBookResultsList).to have_received(:new).with(
          book: book,
          results: mock_search_results,
          pagy: mock_pagy
        )
      end
    end

    context "with pagination" do
      let(:mock_pagy_page) do
        double("pagy").tap { allow(it).to receive_messages(page: 2, next: 3) } # rubocop:disable RSpec/VerifiedDoubles
      end

      before do
        allow_any_instance_of(BooksController).to receive(:pagy_meilisearch).and_return([ mock_pagy_page, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
      end

      it "replaces the correct pagination element for subsequent pages" do
        get book_search_path(book), params: { query: "test query", page: "2" }, as: :turbo_stream

        expect(response.body).to include('turbo-stream action="replace" target="results_list_2"')
      end
    end
  end
end
