require "test_helper"

class ApiV1AuthorsTest < ApplicationTest
  test "lists authors with pagination" do
    author = create(:author, name: "Ruby Author")
    Author.index_documents([ author ], true)

    get "/api/v1/authors", params: { q: "ruby", page: 1 }

    assert_response :success
    assert_kind_of Array, body.fetch("authors")
    assert body.key?("pagination")
  end

  test "returns an author without expansions" do
    author = create(:author)

    get "/api/v1/authors/#{author.id}"

    assert_response :success
    assert_equal author.id, body.fetch("id")
    refute body.key?("pagination")
    refute body.key?("books")
  end

  test "expands an author's books" do
    author = create(:author)
    create(:book, author:)

    get "/api/v1/authors/#{author.id}", params: { expand: [ "books" ] }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")
  end

  test "caps the author books limit at 1000" do
    author = create(:author)

    get "/api/v1/authors/#{author.id}", params: { expand: [ "books" ], limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  test "returns not found for hidden authors" do
    author = create(:author, hidden: true)

    get "/api/v1/authors/#{author.id}"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
