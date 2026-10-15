require "test_helper"

class CategoriesTest < ApplicationTest
  setup do
    @category = create(:category, name: "Programming")
  end

  test "lists categories" do
    get categories_path

    assert_response :ok
  end

  test "renders visible category books in HTML and Turbo Stream" do
    book = create(:book, category: @category, title: "Ruby Programming", hidden: false)
    create(:book, category: @category, title: "Hidden Book", hidden: true)

    get category_path(id: @category.id)
    assert_response :ok
    assert_includes response.body, book.title
    refute_includes response.body, "Hidden Book"

    get category_path(id: @category.id), as: :turbo_stream
    assert_response :ok
    assert_includes response.body, 'target="results_list_1"'
  end

  test "searches category books with the category filter" do
    book = create(:book, category: @category, title: "Ruby Programming")
    results = [ book ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Book.expects(:pagy_search).with(
      "ruby",
      filter: %((hidden = false OR hidden NOT EXISTS) AND category = "#{@category.id}"),
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).twice.returns(results)
    CategoriesController.any_instance.stubs(:pagy).returns([ pagy, results ])

    get category_path(id: @category.id, q: "ruby"), as: :html
    assert_response :ok
    assert_includes response.body, book.title

    get category_path(id: @category.id, q: "ruby"), as: :turbo_stream
    assert_response :ok
    assert_includes response.body, book.title
  end

  test "caps category search limits at one thousand" do
    results = [ create(:book, category: @category) ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Book.stubs(:pagy_search).returns(results)
    controller = CategoriesController.new
    controller.expects(:pagy).with(:meilisearch, results, limit: 1000).returns([ pagy, results ])
    CategoriesController.stubs(:new).returns(controller)

    get category_path(id: @category.id, q: "ruby", limit: 1500)
  end

  test "renders a turbo stream for a later page" do
    create_list(:book, 25, category: @category, hidden: false)

    get category_path(id: @category.id, page: 2), as: :turbo_stream

    assert_response :ok
    assert_includes response.body, 'target="results_list_2"'
  end
end
