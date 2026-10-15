require "test_helper"

class ApiV1CategoriesTest < ApplicationTest
  test "lists categories" do
    category = create(:category)

    get "/api/v1/categories"

    assert_response :success
    assert_includes body.fetch("categories").pluck("id"), category.id
  end

  test "returns a category without expansions" do
    category = create(:category)

    get "/api/v1/categories/#{category.id}"

    assert_response :success
    assert_equal category.id, body.fetch("id")
    refute body.key?("pagination")
    refute body.key?("books")
  end

  test "expands a category's books" do
    category = create(:category)
    create(:book, category:)

    get "/api/v1/categories/#{category.id}", params: { expand: [ "books" ] }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("books")
  end

  test "caps the category books limit at 1000" do
    category = create(:category)

    get "/api/v1/categories/#{category.id}", params: { expand: [ "books" ], limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  test "returns not found for a missing category" do
    get "/api/v1/categories/0"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
