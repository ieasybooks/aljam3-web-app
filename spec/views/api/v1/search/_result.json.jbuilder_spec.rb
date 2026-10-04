require "rails_helper"

RSpec.describe "api/v1/search/_result.json.jbuilder" do
  it "identifies the result's volume while retaining its content and page number" do
    page = build_stubbed(:page, number: 7, content: "العلم والعمل")

    rendered = Api::V1::SearchController.render(
      partial: "api/v1/search/result", formats: [ :json ], locals: { page: }
    )

    expect(JSON.parse(rendered)).to include(
      "id" => page.id, "file_id" => page.book_file_id,
      "number" => 7, "content" => "العلم والعمل",
      "book" => include("id" => page.file.book.id)
    )
  end
end
