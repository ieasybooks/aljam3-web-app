require "test_helper"

class PageTest < ModelTest
  test "has the expected associations and validation" do
    assert_model_matcher(belong_to(:file).class_name("BookFile").counter_cache(true), Page)
    assert_model_matcher(have_many(:search_clicks).dependent(:delete_all), Page)
    assert_model_matcher(validate_presence_of(:content), Page)
  end

  test "configures Meilisearch fields" do
    Page.index.number_of_documents

    assert_equal [ "content" ], Page.index.searchable_attributes
    assert_equal [ "library", "book", "author", "category", "hidden" ], Page.index.filterable_attributes
  end
end
