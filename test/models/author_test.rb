require "test_helper"

class AuthorTest < ModelTest
  test "has the expected associations and validation" do
    assert_model_matcher(have_many(:books).dependent(:destroy), Author)
    assert_model_matcher(have_many(:search_clicks).dependent(:delete_all), Author)
    assert_model_matcher(validate_presence_of(:name), Author)
  end

  test "configures Meilisearch fields" do
    settings = Author.meilisearch_settings.to_settings

    assert_equal [ :name ], settings.fetch(:searchable_attributes)
    assert_equal [ :hidden ], settings.fetch(:filterable_attributes)
  end
end
