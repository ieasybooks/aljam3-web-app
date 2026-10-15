require "test_helper"

describe "API v1 files" do
  it "returns a file without page expansion" do
    file = create(:book_file)

    get "/api/v1/files/#{file.id}"

    assert_response :success
    assert_equal file.id, body.fetch("id")
    refute body.key?("pagination")
    refute body.key?("pages")
  end

  it "expands a file's pages" do
    file = create(:book_file)
    create(:page, file:, number: 7)

    get "/api/v1/files/#{file.id}", params: { expand: [ "pages" ] }

    assert_response :success
    assert body.key?("pagination")
    assert body.key?("pages")
  end

  it "caps the file pages limit at 1000" do
    file = create(:book_file)

    get "/api/v1/files/#{file.id}", params: { expand: [ "pages" ], limit: 1500 }

    assert_response :success
    assert_equal 1000, body.dig("pagination", "limit")
  end

  it "returns not found for a missing file" do
    get "/api/v1/files/0"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  it "returns not found for a file belonging to a hidden book" do
    file = create(:book_file, book: create(:book, hidden: true))

    get "/api/v1/files/#{file.id}"

    assert_response :not_found
    assert_equal "Resource not found", body.fetch("error")
  end

  private

  def body
    JSON.parse(response.body)
  end
end
