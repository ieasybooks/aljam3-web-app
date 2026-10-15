require "test_helper"

class StaticTest < ApplicationTest
  setup do
    @book = create(:book)
    @page = create(:page)
    @author = create(:author)
    @pagy = Pagy::Offset.new(count: 1, page: 1)

    @book.stubs(:formatted).returns({ "title" => "<mark>#{@book.title}</mark>" })
    @page.stubs(:formatted).returns({ "content" => "<mark>page content</mark>" })
    @author.stubs(:formatted).returns({ "name" => "<mark>author</mark>" })
    stub_home_collections
  end

  test "renders the home page without a query" do
    get root_path

    assert_response :success
  end

  test "signs in a user from a native handoff token" do
    user = create(:user)
    token = user.signed_id(purpose: "native_handoff")

    get root_path, params: { sign_in_token: token }

    assert_response :success
    assert_equal user, request.env["warden"].user
  end

  test "searches all tabs and creates a query with compact refinements" do
    stub_search_results
    user = create(:user)
    StaticController.any_instance.stubs(:current_user).returns(user)

    assert_difference("SearchQuery.count", 1) do
      get root_path, params: { q: "test query", l: @book.library_id, c: @book.category_id, a: @book.author_id }
    end

    query = SearchQuery.last
    assert_equal "test query", query.query
    assert_equal({ "library" => @book.library_id.to_s, "category" => @book.category_id.to_s, "author" => @book.author_id.to_s }, query.refinements)
    assert_equal user, query.user
  end

  test "builds model-specific search results and filters" do
    results = [ @page ]
    Page.expects(:pagy_search).with(
      "logic",
      filter: "(hidden = false OR hidden NOT EXISTS) AND library = \"#{@book.library_id}\" AND category = \"#{@book.category_id}\" AND author = \"#{@book.author_id}\"",
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).returns(results)
    StaticController.any_instance.stubs(:pagy).returns([ @pagy, results ])
    Components::SearchResultsList.stubs(:new).returns(mock(to_s: "component"))

    get root_path, params: { q: "logic", m: "page", l: @book.library_id, c: @book.category_id, a: @book.author_id, page: 2 }

    assert_response :ok
    assert_includes response.body, "component"
  end

  test "does not apply refinements to author search" do
    results = [ @author ]
    Author.expects(:pagy_search).with(
      "author",
      filter: "(hidden = false OR hidden NOT EXISTS)",
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).returns(results)
    StaticController.any_instance.stubs(:pagy).returns([ @pagy, results ])
    Components::SearchResultsList.stubs(:new).returns(mock(to_s: "component"))

    get root_path, params: { q: "author", m: "author", l: "ignored", c: "ignored", a: "ignored" }

    assert_response :ok
  end

  test "ignores select-all and blank refinements" do
    results = [ @book ]
    Book.stubs(:pagy_search).returns(results)
    StaticController.any_instance.stubs(:pagy).returns([ @pagy, results ])
    Components::SearchResultsList.stubs(:new).returns(mock(to_s: "component"))

    get root_path, params: { q: "book", m: "book", l: "a", c: "", a: nil }

    assert_response :ok
  end

  test "uses an existing qid and skips query creation during prefetch" do
    user = create(:user)
    StaticController.any_instance.stubs(:current_user).returns(user)
    Book.stubs(:pagy_search).returns([ @book ])
    StaticController.any_instance.stubs(:pagy).returns([ @pagy, [ @book ] ])
    Components::SearchResultsList.stubs(:new).returns(mock(to_s: "component"))

    assert_no_difference("SearchQuery.count") do
      get root_path, params: { q: "book", m: "book", qid: "existing" }, headers: { "X-Sec-Purpose" => "prefetch" }
    end
    assert_response :ok
  end

  test "does not create a query when search results are empty" do
    Book.stubs(:pagy_search).returns([])
    StaticController.any_instance.stubs(:pagy).returns([ @pagy, [] ])
    Components::SearchResultsList.stubs(:new).returns(mock(to_s: "component"))

    assert_no_difference("SearchQuery.count") do
      get root_path, params: { q: "missing", m: "book" }
    end
    assert_response :ok
  end

  test "renders the privacy page" do
    get "/privacy"

    assert_response :success
  end

  private

  def stub_home_collections
    books_relation = mock("books relation")
    books_relation.stubs(:order).returns(books_relation)
    books_relation.stubs(:limit).returns(books_relation)
    books_relation.stubs(:pluck).returns([ @book.id ])
    Book.stubs(:where).returns(books_relation)
    Book.stubs(:where).with(id: [ @book.id ]).returns([ @book ])

    libraries = mock("libraries")
    libraries.stubs(:order).returns(libraries)
    libraries.stubs(:pluck).returns([ [ 1, "Main Library" ] ])
    Library.stubs(:all).returns(libraries)

    categories = mock("categories")
    categories.stubs(:pluck).returns([ [ 1, "Fiction", 1 ] ])
    Category.stubs(:order).returns(categories)
  end

  def stub_search_results
    Page.stubs(:pagy_search).returns([ @page ])
    Book.stubs(:pagy_search).returns([ @book ])
    Author.stubs(:pagy_search).returns([ @author ])
    StaticController.any_instance.stubs(:pagy).returns(
      [ @pagy, [ @page ] ],
      [ @pagy, [ @book ] ],
      [ @pagy, [ @author ] ]
    )
  end
end
