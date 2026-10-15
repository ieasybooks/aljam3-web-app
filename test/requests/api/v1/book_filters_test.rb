require "test_helper"

class ApiV1BookFiltersTest < ApplicationTest
  setup do
    @matching = create(:book, title: "Aljam3 Filter Book")
    create(:book, title: "Aljam3 other", author: @matching.author, category: @matching.category)
    create(:book, title: "Aljam3 other", author: @matching.author, library: @matching.library)
    create(:book, title: "Aljam3 other", category: @matching.category, library: @matching.library)
    create(:book, title: "Aljam3 hidden", **@matching.attributes.slice("author_id", "category_id", "library_id").symbolize_keys, hidden: true)
  end

  test "combines every scope before pagination and excludes hidden books" do
    get "/api/v1/books", params: filters.merge(limit: 1)

    assert_response :ok
    assert_equal [ @matching.id ], response.parsed_body.fetch("books").pluck("id")
    assert_equal 1, response.parsed_body.dig("pagination", "count")
    assert_equal filters.stringify_keys, response.parsed_body.fetch("filters")
  end

  test "returns no books for an incompatible combination" do
    get "/api/v1/books", params: filters.merge(category: 999_999_999)

    assert_empty response.parsed_body.fetch("books")
  end

  test "applies the same filters to title searches" do
    results = [ @matching ]
    Book.expects(:pagy_search).with(
      "Aljam3",
      filter: "hidden = false AND library = #{@matching.library_id} AND author = #{@matching.author_id} AND category = #{@matching.category_id}",
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).returns(results)
    Api::V1::BooksController.any_instance.stubs(:pagy).returns([ Pagy::Offset.new(count: 1, page: 1), results ])

    get "/api/v1/books", params: filters.merge(q: "Aljam3")

    assert_equal filters.stringify_keys, response.parsed_body.fetch("filters")
    assert_equal [ @matching.id ], response.parsed_body.fetch("books").pluck("id")
    assert_equal 1, response.parsed_body.dig("pagination", "count")
  end

  test "rejects malformed filters" do
    [ "0", "-1", "1 OR hidden = true", [ "1" ] ].each do |id|
      get "/api/v1/books", params: { author: id }
      assert_response :bad_request
    end
  end

  test "retains the unfiltered listing when no scopes are supplied" do
    get "/api/v1/books"

    assert_response :ok
    assert_equal({}, response.parsed_body.fetch("filters"))
  end

  private

  def filters
    { author: @matching.author_id, category: @matching.category_id, library: @matching.library_id }
  end
end
