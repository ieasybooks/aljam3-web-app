require 'rails_helper'

RSpec.describe "Authors" do
  describe "GET /authors" do
    context "when no authors exist" do
      it "returns an empty array" do # rubocop:disable RSpec/MultipleExpectations
        get authors_path

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json_response = JSON.parse(response.body)
        expect(json_response).to eq([])
      end
    end

    context "when authors exist" do
      let!(:authors) { create_list(:author, 3) } # rubocop:disable RSpec/LetSetup

      it "returns authors ordered by name" do # rubocop:disable RSpec/MultipleExpectations,RSpec/ExampleLength
        get authors_path

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")

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
        get authors_path

        json_response = JSON.parse(response.body)
        author_response = json_response.first

        expect(author_response.keys).to contain_exactly("id", "name")
        expect(author_response.keys).not_to include("created_at", "updated_at", "books_count")
      end

      it "returns correct data types" do # rubocop:disable RSpec/MultipleExpectations
        get authors_path

        json_response = JSON.parse(response.body)
        author_response = json_response.first

        expect(author_response["id"]).to be_an(Integer)
        expect(author_response["name"]).to be_a(String)
      end
    end

    context "with a single author" do
      let!(:author) { create(:author, name: "Single Author") }

      it "returns a single author in an array" do # rubocop:disable RSpec/MultipleExpectations
        get authors_path

        json_response = JSON.parse(response.body)

        expect(json_response).to be_an(Array)
        expect(json_response.length).to eq(1)
        expect(json_response.first).to eq({
          "id" => author.id,
          "name" => "Single Author"
        })
      end
    end
  end
end
