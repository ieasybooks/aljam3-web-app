require "test_helper"

describe "API v1 libraries" do
  it "lists libraries" do
    library = create(:library)

    get "/api/v1/libraries"

    assert_response :success
    assert_includes body.fetch("libraries").pluck("id"), library.id
  end

  it "returns a library without expansions" do
    library = create(:library)

    get "/api/v1/libraries/#{library.id}"

    assert_response :success
    assert_equal library.id, body.fetch("id")
    refute body.key?("pagination")
    refute body.key?("books")
  end

  it "expands a library's books" do
    library = create(:library)
    create(:book, library:)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ] }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")
  end

  it "expands a library's books through search" do
    library = create(:library)
    book = create(:book, library:, title: "Ruby Library Book")
    Book.index_documents([ book ], true)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], q: "ruby" }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")
  end

  it "caps the library books limit at 1000" do
    library = create(:library)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  it "caps the library search limit at 1000" do
    library = create(:library)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], limit: 1500, q: "ruby" }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  it "returns not found for a missing library" do
    get "/api/v1/libraries/0"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
