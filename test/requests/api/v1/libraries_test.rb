require "test_helper"

class ApiV1LibrariesTest < ApplicationTest
  test "lists libraries" do
    library = create(:library)

    get "/api/v1/libraries"

    assert_response :success
    assert_includes body.fetch("libraries").pluck("id"), library.id
  end

  test "returns a library without expansions" do
    library = create(:library)

    get "/api/v1/libraries/#{library.id}"

    assert_response :success
    assert_equal library.id, body.fetch("id")
    refute body.key?("pagination")
    refute body.key?("books")
  end

  test "expands a library's books" do
    library = create(:library)
    create(:book, library:)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ] }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], q: "ruby" }

    assert_response :success
    assert body.key?("pagination")
  end

  test "searches expanded library books" do
    library = create(:library)
    book = create(:book, library:, title: "Ruby Library Book")
    Book.index_documents([ book ], true)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], q: "ruby", limit: 50 }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")
  end

  test "caps expanded book limits at 1000" do
    library = create(:library)

    get "/api/v1/libraries/#{library.id}", params: { expand: [ "books" ], limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  test "returns not found for a missing library" do
    get "/api/v1/libraries/0"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
