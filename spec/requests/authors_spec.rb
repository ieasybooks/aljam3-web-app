require "rails_helper"

RSpec.describe "Authors" do
  describe "GET /authors" do
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

        expect(response.body).to include('target="results_list_"')
      end

      it "includes correct turbo stream target for specific page" do
        create_list(:author, 25)

        get authors_path(page: 2), as: :turbo_stream

        expect(response.body).to include('target="results_list_2"')
      end
    end
  end
end
