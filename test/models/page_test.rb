require "test_helper"

class PageTest < ModelTest
  test "has the expected associations and validation" do
    assert_model_matcher(belong_to(:file).class_name("BookFile").counter_cache(true), Page)
    assert_model_matcher(have_many(:search_clicks).dependent(:delete_all), Page)
    assert_model_matcher(validate_presence_of(:content), Page)
  end

  test "configures Meilisearch fields" do
    settings = Page.meilisearch_settings.to_settings

    assert_equal [ :content ], settings.fetch(:searchable_attributes)
    assert_equal [ :library, :book, :author, :category, :hidden ], settings.fetch(:filterable_attributes)
  end
end
