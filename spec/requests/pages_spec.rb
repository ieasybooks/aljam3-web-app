require "rails_helper"

RSpec.describe "Pages" do
  describe "GET /show" do
    let(:page) { create(:page) }
    let(:search_query) { SearchQuery.create(query: "test query", refinements: { search_scope: "c" }, user: nil) }

    it "returns http success" do
      get book_file_page_path(page.file.book.id, page.file.id, page.number)

      expect(response).to have_http_status(:success)
    end

    context "when SearchClick logic is triggered" do
      context "when qid param is present and X-Sec-Purpose header is not 'prefetch'" do
        it "creates a SearchClick record with default index when no index param is provided" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: search_query.id)
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.index).to eq(-1)
          expect(search_click.search_query_id).to eq(search_query.id)
          expect(search_click.result).to eq(page)
        end

        it "creates a SearchClick record with provided index when index param is provided" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: search_query.id, i: "5")
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.index).to eq(5)
          expect(search_click.search_query_id).to eq(search_query.id)
          expect(search_click.result).to eq(page)
        end

        it "handles invalid index param by converting to 0" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: search_query.id, i: "invalid")
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.index).to eq(0)
          expect(search_click.search_query_id).to eq(search_query.id)
          expect(search_click.result).to eq(page)
        end

        it "handles empty index param by defaulting to -1" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: search_query.id, i: "")
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.index).to eq(-1)
          expect(search_click.search_query_id).to eq(search_query.id)
          expect(search_click.result).to eq(page)
        end
      end

      context "when qid param is present but X-Sec-Purpose header is 'prefetch'" do
        it "does not create a SearchClick record" do
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: search_query.id),
                headers: { "X-Sec-Purpose" => "prefetch" }
          }.not_to change(SearchClick, :count)
        end
      end

      context "when qid param is not present" do
        it "does not create a SearchClick record" do
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number)
          }.not_to change(SearchClick, :count)
        end
      end

      context "when qid param is blank" do
        it "does not create a SearchClick record" do
          expect {
            get book_file_page_path(page.file.book.id, page.file.id, page.number, qid: "")
          }.not_to change(SearchClick, :count)
        end
      end
    end

    context "with different response formats" do
      it "renders HTML format successfully" do # rubocop:disable RSpec/MultipleExpectations
        get book_file_page_path(page.file.book.id, page.file.id, page.number)

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq("text/html")
      end

      context "with turbo_stream format" do
        it "renders turbo_stream format successfully" do # rubocop:disable RSpec/MultipleExpectations
          get book_file_page_path(page.file.book.id, page.file.id, page.number), as: :turbo_stream

          expect(response).to have_http_status(:success)
          expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        end

        context "when page has content" do # rubocop:disable RSpec/NestedGroups
          let(:page) { create(:page, content: "This is some page content.") }

          it "renders the page content with simple_format" do # rubocop:disable RSpec/MultipleExpectations
            get book_file_page_path(page.file.book.id, page.file.id, page.number), as: :turbo_stream

            expect(response).to have_http_status(:success)
            expect(response.body).to include('<turbo-stream action="update" target="txt-content">')
            expect(response.body).to include("<p>This is some page content.</p>")
          end
        end

        context "when page has blank content" do # rubocop:disable RSpec/NestedGroups
          it "renders TxtMessage component with empty page message" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
            stubbed_page = build_stubbed(:page, content: "")
            allow(Page).to receive(:find_by).and_return(stubbed_page)

            get book_file_page_path(stubbed_page.file.book.id, stubbed_page.file.id, stubbed_page.number), as: :turbo_stream

            expect(response).to have_http_status(:success)
            expect(response.body).to include('<turbo-stream action="update" target="txt-content">')
            expect(response.body).to include("الصفحة فارغة") # Arabic translation for "Empty Page"
            expect(response.body).to include("text-gray-500 text-2xl")
            expect(response.body).to include("flex items-center justify-center h-full font-medium text-center")
          end
        end
      end
    end
  end
end
