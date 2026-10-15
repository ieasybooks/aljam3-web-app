require "test_helper"

class ApiV1PagesTest < ApplicationTest
  test "lists the pages for a file" do
    file = create(:book_file)
    page = create(:page, file:, number: 7)

    get "/api/v1/files/#{file.id}/pages"

    assert_response :success
    assert_equal [ { "id" => page.id, "file_id" => file.id, "content" => page.content, "number" => 7 } ], body.fetch("pages")
  end

  test "returns not found for a missing file" do
    get "/api/v1/files/0/pages"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  test "returns not found for a file belonging to a hidden book" do
    file = create(:book_file, book: create(:book, hidden: true))

    get "/api/v1/files/#{file.id}/pages"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
