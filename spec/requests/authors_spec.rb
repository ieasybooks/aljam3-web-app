require "rails_helper"

RSpec.describe "Authors" do
  describe "GET /authors/:id" do
    let(:author) { create(:author) }

    context "when author exists and is not hidden" do
      it "renders the author show view" do
        get author_path(id: author.id)

        expect(response).to have_http_status(:ok)
      end

      context "with search functionality" do
        let!(:matching_book) { create(:book, author:, title: "Ruby Programming", hidden: false) }
        let!(:hidden_book) { create(:book, author:, title: "Hidden Ruby Book", hidden: true) } # rubocop:disable RSpec/LetSetup

        context "with query parameter" do # rubocop:disable RSpec/NestedGroups
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
                [ matching_book ].each_with_index(&block)
              end
            end
          end

          before do
            allow(Book).to receive(:pagy_search).and_return(mock_search_results)
            allow_any_instance_of(AuthorsController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
          end

          context "with HTML format" do # rubocop:disable RSpec/NestedGroups
            it "searches books using Meilisearch with author filter" do
              get author_path(id: author.id, q: "ruby"), as: :html

              expect(Book).to have_received(:pagy_search).with(
                "ruby",
                filter: %(hidden = false AND author = "#{author.id}"),
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              )
            end

            it "renders the author show view with search results" do # rubocop:disable RSpec/MultipleExpectations
              get author_path(id: author.id, q: "ruby"), as: :html

              expect(response.body).to include("Ruby Programming")
              expect(response.body).not_to include("Hidden Ruby Book")
            end
          end

          context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
            it "searches books using Meilisearch with author filter" do
              get author_path(id: author.id, q: "ruby"), as: :turbo_stream

              expect(Book).to have_received(:pagy_search).with(
                "ruby",
                filter: %(hidden = false AND author = "#{author.id}"),
                highlight_pre_tag: "<mark>",
                highlight_post_tag: "</mark>"
              )
            end

            it "renders the author books list with search results" do # rubocop:disable RSpec/MultipleExpectations
              get author_path(id: author.id, q: "ruby"), as: :turbo_stream

              expect(response.body).to include("Ruby Programming")
              expect(response.body).not_to include("Hidden Ruby Book")
            end
          end

          context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
            let(:controller) { AuthorsController.new }

            before do
              allow(AuthorsController).to receive(:new).and_return(controller)
              allow(controller).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ])
              allow(Book).to receive(:pagy_search).and_return(mock_search_results)
            end

            it "uses default limit of 20 when no limit specified" do
              get author_path(id: author.id, q: "ruby"), as: :html

              expect(controller).to have_received(:pagy_meilisearch).with(
                anything,
                limit: 20
              )
            end

            it "uses custom limit when specified" do
              get author_path(id: author.id, q: "ruby", limit: 50), as: :html

              expect(controller).to have_received(:pagy_meilisearch).with(
                anything,
                limit: 50
              )
            end

            it "caps limit at 1000 when higher value is provided" do
              get author_path(id: author.id, q: "ruby", limit: 1500), as: :html

              expect(controller).to have_received(:pagy_meilisearch).with(
                anything,
                limit: 1000
              )
            end

            it "uses limit 0 when invalid limit is provided" do
              get author_path(id: author.id, q: "ruby", limit: "invalid"), as: :html

              expect(controller).to have_received(:pagy_meilisearch).with(
                anything,
                limit: 0
              )
            end
          end
        end

        context "without query parameter" do # rubocop:disable RSpec/NestedGroups
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
                [ matching_book ].each_with_index(&block)
              end
            end
          end

          before do
            allow_any_instance_of(AuthorsController).to receive(:pagy).and_return([ mock_pagy, mock_books_relation ]) # rubocop:disable RSpec/AnyInstance
          end

          context "with HTML format" do # rubocop:disable RSpec/NestedGroups
            it "uses regular ActiveRecord query through author association" do
              allow(author).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
              allow(Author).to receive(:find).with(author.id.to_s).and_return(author)

              get author_path(id: author.id), as: :html

              expect(author).to have_received(:books)
            end

            it "does not call Meilisearch" do
              allow(Book).to receive(:pagy_search)

              get author_path(id: author.id), as: :html

              expect(Book).not_to have_received(:pagy_search)
            end
          end

          context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
            it "uses regular ActiveRecord query through author association" do
              allow(author).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
              allow(Author).to receive(:find).with(author.id.to_s).and_return(author)

              get author_path(id: author.id), as: :turbo_stream

              expect(author).to have_received(:books)
            end

            it "does not call Meilisearch" do
              allow(Book).to receive(:pagy_search)

              get author_path(id: author.id), as: :turbo_stream

              expect(Book).not_to have_received(:pagy_search)
            end
          end

          context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
            let(:controller) { AuthorsController.new }

            before do
              allow(AuthorsController).to receive(:new).and_return(controller)
              allow(controller).to receive(:pagy).and_return([ mock_pagy, mock_books_relation ])

              allow(author).to receive(:books).and_return(double.tap { allow(it).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:title).and_return(mock_books_relation) }) }) # rubocop:disable RSpec/VerifiedDoubles
              allow(Author).to receive(:find).with(author.id.to_s).and_return(author)
            end

            it "uses default limit of 20 when no limit specified" do
              get author_path(id: author.id), as: :html

              expect(controller).to have_received(:pagy).with(
                anything,
                limit: 20
              )
            end

            it "uses custom limit when specified" do
              get author_path(id: author.id, limit: 50), as: :html

              expect(controller).to have_received(:pagy).with(
                anything,
                limit: 50
              )
            end

            it "caps limit at 1000 when higher value is provided" do
              get author_path(id: author.id, limit: 1500), as: :html

              expect(controller).to have_received(:pagy).with(
                anything,
                limit: 1000
              )
            end

            it "uses limit 0 when invalid limit is provided" do
              get author_path(id: author.id, limit: "invalid"), as: :html

              expect(controller).to have_received(:pagy).with(
                anything,
                limit: 0
              )
            end
          end
        end
      end

      context "with books" do
        let!(:hidden_book) { create(:book, author:, hidden: true) }

        it "displays only non-hidden books" do
          create_list(:book, 3, author:, hidden: false)

          get author_path(id: author.id)

          expect(response.body).not_to include(hidden_book.title)
        end

        it "orders books by title" do
          # Create books with specific titles to test ordering
          book_a = create(:book, author:, title: "A Book", hidden: false)
          book_z = create(:book, author:, title: "Z Book", hidden: false)

          get author_path(id: author.id)

          expect(response.body.index(book_a.title)).to be < response.body.index(book_z.title)
        end
      end

      context "with pagination" do
        before do
          create_list(:book, 25, author:, hidden: false)
        end

        it "handles paginated requests with turbo stream" do
          get author_path(id: author.id, page: 2), as: :turbo_stream

          expect(response.body).to include('target="results_list_2"')
        end

        it "renders regular view for page 1" do
          get author_path(id: author.id, page: 1)

          expect(response.content_type).to eq("text/html; charset=utf-8")
        end

        it "renders regular view when no page parameter" do
          get author_path(id: author.id)

          expect(response.content_type).to eq("text/html; charset=utf-8")
        end
      end
    end

    context "with search click tracking" do
      let(:user) { create(:user) }

      before do
        sign_in user
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
      end

      context "without search query parameters" do
        it "does not create a SearchClick" do
          expect { get author_path(id: author.id) }.not_to change(SearchClick, :count)
        end
      end

      context "with search query parameters" do
        let(:search_query) { SearchQuery.create!(query: "test query", refinements: { author: author.id }, user: user) }

        it "creates a SearchClick when qid is present" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get author_path(id: author.id), params: { qid: search_query.id, i: "3" }
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.search_query_id).to eq(search_query.id)
          expect(search_click.result).to eq(author)
          expect(search_click.index).to eq(3)
        end

        it "defaults index to -1 when i parameter is missing" do # rubocop:disable RSpec/MultipleExpectations
          expect {
            get author_path(id: author.id), params: { qid: search_query.id }
          }.to change(SearchClick, :count).by(1)

          search_click = SearchClick.last
          expect(search_click.index).to eq(-1)
        end

        it "does not create SearchClick when request is prefetch" do
          expect {
            get author_path(id: author.id),
                params: { qid: search_query.id, i: "3" },
                headers: { "X-Sec-Purpose" => "prefetch" }
          }.not_to change(SearchClick, :count)
        end

        it "does not create SearchClick when qid is blank" do
          expect {
            get author_path(id: author.id), params: { qid: "", i: "3" }
          }.not_to change(SearchClick, :count)
        end

        it "renders the author show view after creating SearchClick" do
          get author_path(id: author.id), params: { qid: search_query.id, i: "3" }

          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when author is hidden" do
      let(:hidden_author) { create(:author, hidden: true) }

      it "redirects to root path" do
        get author_path(id: hidden_author.id)

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /authors" do
    context "with search functionality" do
      let!(:john_author) { create(:author, name: "John Doe", hidden: false) }
      let!(:jane_author) { create(:author, name: "Jane Smith", hidden: false) }
      let!(:hidden_author) { create(:author, name: "Hidden Author", hidden: true) } # rubocop:disable RSpec/LetSetup

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
              [ john_author, jane_author ].each_with_index(&block)
            end
          end
        end

        before do
          allow(Author).to receive(:pagy_search).and_return(mock_search_results)
          allow_any_instance_of(AuthorsController).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "searches authors using Meilisearch" do
            get authors_path(q: "john"), as: :html

            expect(Author).to have_received(:pagy_search).with(
              "john",
              filter: "hidden = false",
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the authors list" do # rubocop:disable RSpec/MultipleExpectations
            get authors_path(q: "john"), as: :html

            expect(response.body).to include("John Doe")
            expect(response.body).to include("Jane Smith")
            expect(response.body).not_to include("Hidden Author")
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "searches authors using Meilisearch" do
            get authors_path(q: "jane"), as: :turbo_stream

            expect(Author).to have_received(:pagy_search).with(
              "jane",
              filter: "hidden = false",
              highlight_pre_tag: "<mark>",
              highlight_post_tag: "</mark>"
            )
          end

          it "renders the authors list" do # rubocop:disable RSpec/MultipleExpectations
            get authors_path(q: "jane"), as: :turbo_stream

            expect(response.body).to include("Jane Smith")
            expect(response.body).to include("John Doe")
            expect(response.body).not_to include("Hidden Author")
          end
        end

        context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
          let(:controller) { AuthorsController.new }

          before do
            allow(AuthorsController).to receive(:new).and_return(controller)
            allow(controller).to receive(:pagy_meilisearch).and_return([ mock_pagy, mock_search_results ])
          end

          it "uses default limit of 20 when no limit specified" do
            get authors_path(q: "john"), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 20
            )
          end

          it "uses custom limit when specified" do
            get authors_path(q: "john", limit: 50), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 50
            )
          end

          it "caps limit at 1000 when higher value is provided" do
            get authors_path(q: "john", limit: 1500), as: :html

            expect(controller).to have_received(:pagy_meilisearch).with(
              anything,
              limit: 1000
            )
          end

          it "uses limit 0 when invalid limit is provided" do
            get authors_path(q: "john", limit: "invalid"), as: :html

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

        let(:mock_authors_relation) do
          double("authors_relation").tap do |relation| # rubocop:disable RSpec/VerifiedDoubles
            allow(relation).to receive_messages(
              any?: true,
              size: 2
            )

            allow(relation).to receive(:each_with_index) do |&block|
              [ john_author, jane_author ].each_with_index(&block)
            end
          end
        end

        before do
          allow(Author).to receive(:where).with(hidden: false).and_return(double.tap { allow(it).to receive(:order).with(:name).and_return(mock_authors_relation) }) # rubocop:disable RSpec/VerifiedDoubles
          allow_any_instance_of(AuthorsController).to receive(:pagy).and_return([ mock_pagy, mock_authors_relation ]) # rubocop:disable RSpec/AnyInstance
        end

        context "with HTML format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query" do
            get authors_path, as: :html

            expect(Author).to have_received(:where).with(hidden: false)
          end

          it "does not call Meilisearch" do
            allow(Author).to receive(:pagy_search)

            get authors_path, as: :html

            expect(Author).not_to have_received(:pagy_search)
          end
        end

        context "with Turbo Stream format" do # rubocop:disable RSpec/NestedGroups
          it "uses regular ActiveRecord query" do
            get authors_path, as: :turbo_stream

            expect(Author).to have_received(:where).with(hidden: false)
          end

          it "does not call Meilisearch" do
            allow(Author).to receive(:pagy_search)

            get authors_path, as: :turbo_stream

            expect(Author).not_to have_received(:pagy_search)
          end
        end

        context "with limit parameter" do # rubocop:disable RSpec/NestedGroups,RSpec/MultipleMemoizedHelpers
          let(:controller) { AuthorsController.new }

          before do
            allow(AuthorsController).to receive(:new).and_return(controller)
            allow(controller).to receive(:pagy).and_return([ mock_pagy, mock_authors_relation ])
          end

          it "uses default limit of 20 when no limit specified" do
            get authors_path, as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 20
            )
          end

          it "uses custom limit when specified" do
            get authors_path(limit: 50), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 50
            )
          end

          it "caps limit at 1000 when higher value is provided" do
            get authors_path(limit: 1500), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 1000
            )
          end

          it "uses limit 0 when invalid limit is provided" do
            get authors_path(limit: "invalid"), as: :html

            expect(controller).to have_received(:pagy).with(
              anything,
              limit: 0
            )
          end
        end
      end
    end

    context "with JSON format" do
      context "when no authors exist" do
        it "returns an empty array" do
          get authors_path, as: :json

          expect(JSON.parse(response.body)).to eq([])
        end
      end

      context "when authors exist" do
        let!(:authors) { create_list(:author, 3) }

        it "returns authors ordered by name" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
          get authors_path, as: :json

          json_response = JSON.parse(response.body)

          expect(json_response).to be_an(Array)
          expect(json_response.length).to eq(3)

           expected_order = [
            { "id" => authors[0].id, "name" => authors[0].name },
            { "id" => authors[1].id, "name" => authors[1].name },
            { "id" => authors[2].id, "name" => authors[2].name }
          ]

          expect(json_response).to eq(expected_order)
        end

        it "includes only id and name fields" do # rubocop:disable RSpec/MultipleExpectations
          get authors_path, as: :json

          json_response = JSON.parse(response.body)
          author_response = json_response.first

          expect(author_response.keys).to contain_exactly("id", "name")
          expect(author_response.keys).not_to include("created_at", "updated_at", "books_count")
        end

        it "returns correct data types" do # rubocop:disable RSpec/MultipleExpectations
          get authors_path, as: :json

          json_response = JSON.parse(response.body)
          author_response = json_response.first

          expect(author_response["id"]).to be_an(Integer)
          expect(author_response["name"]).to be_a(String)
        end

        it "sets cache headers" do # rubocop:disable RSpec/MultipleExpectations
          get authors_path, as: :json

          expect(response.headers["Cache-Control"]).to include("max-age=604800")
          expect(response.headers["Cache-Control"]).to include("public")
        end
      end

      context "with a hidden author" do
        it "does not return hidden authors" do
          create(:author, name: "Hidden Author", hidden: true)

          get authors_path, as: :json

          json_response = JSON.parse(response.body)

          expect(json_response.length).to eq(0)
        end
      end
    end

    context "with HTML format" do
      it "renders HTML response" do
        get authors_path, as: :html

        expect(response.content_type).to eq("text/html; charset=utf-8")
      end

      it "excludes hidden authors" do
        create(:author, name: "Hidden Author", hidden: true)

        get authors_path, as: :html

        expect(response.body).not_to include("Hidden Author")
      end
    end

    context "with Turbo Stream format" do
      it "renders turbo stream response" do
        get authors_path, as: :turbo_stream

        expect(response.content_type).to eq("text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "excludes hidden authors" do
        create(:author, name: "Hidden Author", hidden: true)

        get authors_path, as: :turbo_stream

        expect(response.body).not_to include("Hidden Author")
      end

      it "includes correct turbo stream target for first page" do
        get authors_path, as: :turbo_stream

        expect(response.body).to include('target="results_list_1"')
      end

      it "includes correct turbo stream target for specific page" do
        create_list(:author, 25)

        get authors_path(page: 2), as: :turbo_stream

        expect(response.body).to include('target="results_list_2"')
      end
    end
  end
end
