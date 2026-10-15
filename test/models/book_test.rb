require "test_helper"

class BookTest < ModelTest
  test "has the expected associations and validations" do
    assert_model_matcher(belong_to(:library).counter_cache(true), Book)
    assert_model_matcher(belong_to(:author).counter_cache(true), Book)
    assert_model_matcher(belong_to(:category).counter_cache(true), Book)
    assert_model_matcher(have_many(:files).class_name("BookFile").dependent(:destroy), Book)
    assert_model_matcher(have_many(:pages).through(:files), Book)
    assert_model_matcher(have_many(:search_clicks).dependent(:delete_all), Book)
    assert_model_matcher(validate_presence_of(:title), Book)
    assert_model_matcher(validate_presence_of(:volumes), Book)
    assert_model_matcher(validate_presence_of(:pages_count), Book)
  end

  test "configures Meilisearch fields" do
    settings = Book.meilisearch_settings.to_settings

    assert_equal [ :title ], settings.fetch(:searchable_attributes)
    assert_equal [ :library, :author, :category, :hidden ], settings.fetch(:filterable_attributes)
  end

  test "increments the view count" do
    book = create(:book, views_count: 5)

    assert_changes -> { book.reload.views_count }, from: 5, to: 6 do
      book.increment_views!
    end
  end

  test "returns visible books ordered by view count" do
    book_10 = create(:book, views_count: 10)
    book_5 = create(:book, views_count: 5)
    book_8 = create(:book, views_count: 8)

    assert_equal [ book_10, book_8, book_5 ], Book.most_viewed
  end

  test "excludes hidden books from most viewed" do
    create(:book, views_count: 10, hidden: true)
    book_5 = create(:book, views_count: 5)
    book_8 = create(:book, views_count: 8)

    assert_equal [ book_8, book_5 ], Book.most_viewed
  end
end
