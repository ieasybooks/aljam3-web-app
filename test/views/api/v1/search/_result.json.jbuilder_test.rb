require "test_helper"

class ApiV1SearchResultJsonJbuilderTest < ApplicationTest
  test "renders the result metadata, content, and page number" do
    page = build_stubbed(:page, number: 7, content: "العلم والعمل")

    rendered = Api::V1::SearchController.render(
      partial: "api/v1/search/result", formats: [ :json ], locals: { page: }
    )
    result = JSON.parse(rendered)

    assert_equal page.id, result.fetch("id")
    assert_equal page.book_file_id, result.fetch("file_id")
    assert_equal 7, result.fetch("number")
    assert_equal "العلم والعمل", result.fetch("content")
    assert_equal page.file.book.id, result.dig("book", "id")
  end
end
