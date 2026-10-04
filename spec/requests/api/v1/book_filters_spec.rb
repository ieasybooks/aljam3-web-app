require "rails_helper"

RSpec.describe "Book filters", :aggregate_failures do
  let(:matching) { create(:book, title: "Aljam3 Filter Book") }
  let(:filters) { { author: matching.author_id, category: matching.category_id, library: matching.library_id } }

  before do
    create(:book, title: "Aljam3 other", author: matching.author, category: matching.category)
    create(:book, title: "Aljam3 other", author: matching.author, library: matching.library)
    create(:book, title: "Aljam3 other", category: matching.category, library: matching.library)
    create(:book, title: "Aljam3 hidden", **matching.attributes.slice("author_id", "category_id", "library_id").symbolize_keys, hidden: true)
  end

  it "combines every scope before pagination and excludes hidden books" do
    get "/api/v1/books", params: filters.merge(limit: 1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("books").pluck("id")).to eq([ matching.id ])
    expect(response.parsed_body.dig("pagination", "count")).to eq(1)
    expect(response.parsed_body.fetch("filters")).to eq(filters.stringify_keys)
  end

  it "returns no books for an incompatible combination" do
    get "/api/v1/books", params: filters.merge(category: 999_999_999)
    expect(response.parsed_body.fetch("books")).to be_empty
  end

  it "applies the same AND filters to title searches" do
    Book.index_documents(Book.all.to_a, true)
    get "/api/v1/books", params: filters.merge(q: "Aljam3")
    expect(response.parsed_body.fetch("filters")).to eq(filters.stringify_keys)
    expect(response.parsed_body.fetch("books").pluck("id")).to eq([ matching.id ])
    expect(response.parsed_body.dig("pagination", "count")).to eq(1)
  end

  it "does not broaden malformed filters into an unfiltered request" do
    [ "0", "-1", "1 OR hidden = true", [ "1" ] ].each do |id|
      get "/api/v1/books", params: { author: id }
      expect(response).to have_http_status(:bad_request)
    end
  end

  it "retains unfiltered listing when no scopes are supplied" do
    get "/api/v1/books"
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch("filters")).to eq({})
  end
end
