require "test_helper"

class BooksTest < ApplicationTest
  setup do
    @book = create(:book, :with_files, title: "Ruby Programming", hidden: false)
  end

  test "lists visible books in HTML and Turbo Stream" do
    create(:book, title: "Hidden Book", hidden: true)

    get books_path, as: :html
    assert_response :ok
    assert_includes response.body, @book.title
    refute_includes response.body, "Hidden Book"

    get books_path, as: :turbo_stream
    assert_response :ok
    assert_includes response.body, 'target="results_list_1"'
  end

  test "orders books by title and renders later pages" do
    first = create(:book, title: "A Book", hidden: false)
    last = create(:book, title: "Z Book", hidden: false)

    get books_path
    assert_operator response.body.index(first.title), :<, response.body.index(last.title)

    create_list(:book, 25, hidden: false)
    get books_path(page: 2), as: :turbo_stream
    assert_includes response.body, 'target="results_list_2"'
  end

  test "searches books with the expected filter" do
    results = [ @book ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Book.expects(:pagy_search).with(
      "ruby",
      filter: "hidden = false",
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).twice.returns(results)
    BooksController.any_instance.stubs(:pagy).returns([ pagy, results ])

    get books_path(q: "ruby"), as: :html
    assert_response :ok
    assert_includes response.body, @book.title

    get books_path(q: "ruby"), as: :turbo_stream
    assert_response :ok
    assert_includes response.body, @book.title
  end

  test "caps search limits at one thousand" do
    results = [ @book ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Book.stubs(:pagy_search).returns(results)
    controller = BooksController.new
    controller.expects(:pagy).with(:meilisearch, results, limit: 1000).returns([ pagy, results ])
    BooksController.stubs(:new).returns(controller)

    get books_path(q: "ruby", limit: 1500)
  end

  test "redirects to the first page and tracks a search click" do
    get book_path(book_id: @book.id)
    assert_redirected_to book_file_page_path(book_id: @book.id, file_id: @book.pages.first.file.id, page_number: @book.pages.first.number)

    user = create(:user)
    query = SearchQuery.create!(query: "ruby", refinements: { book: @book.id }, user:)
    sign_in user
    assert_difference("SearchClick.count", 1) do
      get book_path(book_id: @book.id), params: { qid: query.id, i: "3" }
    end
    assert_equal [ query.id, @book.id, 3 ], [ SearchClick.last.search_query_id, SearchClick.last.result_id, SearchClick.last.index ]

    assert_difference("SearchClick.count", 1) do
      get book_path(book_id: @book.id), params: { qid: query.id }
    end
    assert_equal(-1, SearchClick.last.index)

    assert_no_difference("SearchClick.count") do
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).returns(nil)
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).with("X-Sec-Purpose").returns("prefetch")
      get book_path(book_id: @book.id), params: { qid: query.id }
    end
  end

  test "searches pages and creates a query only for a new non-prefetch search" do
    results = [ @book.pages.first ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Page.stubs(:pagy_search).returns(results)
    BooksController.any_instance.stubs(:pagy).returns([ pagy, results ])

    assert_difference("SearchQuery.count", 1) do
      get book_search_path(book_id: @book.id), params: { q: "page" }, as: :turbo_stream
    end
    assert_response :ok
    assert_includes response.body, 'target="results_list_1"'

    assert_no_difference("SearchQuery.count") do
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).returns(nil)
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).with("X-Sec-Purpose").returns("prefetch")
      get book_search_path(book_id: @book.id), params: { q: "page" }, as: :turbo_stream
    end
  end

  test "does not create a query for empty page search results" do
    results = []
    pagy = Pagy::Offset.new(count: 0, page: 1)
    Page.stubs(:pagy_search).returns(results)
    BooksController.any_instance.stubs(:pagy).returns([ pagy, results ])

    assert_no_difference("SearchQuery.count") do
      get book_search_path(book_id: @book.id), params: { q: "missing" }, as: :turbo_stream
    end
    assert_response :ok
  end

  test "skips the click when the book show request is a prefetch" do
    controller = BooksController.new
    controller.instance_variable_set(:@book, @book)
    controller.stubs(:params).returns(ActionController::Parameters.new(qid: "query", i: "3"))
    controller.stubs(:request).returns(mock(headers: { "X-Sec-Purpose" => "prefetch" }))
    controller.stubs(:book_file_page_path).returns("/")
    controller.stubs(:redirect_to)

    assert_no_difference("SearchClick.count") { controller.show }
  end
end
