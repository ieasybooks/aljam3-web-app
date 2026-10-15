require "test_helper"

class AuthorsTest < ApplicationTest
  setup do
    @author = create(:author, name: "Test Author", hidden: false)
  end

  test "renders an author and its visible books" do
    visible = create(:book, author: @author, title: "A Visible Book", hidden: false)
    create(:book, author: @author, title: "A Hidden Book", hidden: true)

    get author_path(id: @author.id)

    assert_response :ok
    assert_includes response.body, visible.title
    refute_includes response.body, "A Hidden Book"
  end

  test "redirects hidden authors" do
    hidden = create(:author, hidden: true)

    get author_path(id: hidden.id)

    assert_redirected_to root_path
  end

  test "searches author books through Meilisearch for HTML and Turbo Stream" do
    book = create(:book, author: @author, title: "Ruby Programming", hidden: false)
    results = [ book ]
    pagy = Pagy::Offset.new(count: 1, page: 1)

    Book.expects(:pagy_search).with(
      "ruby",
      filter: %(hidden = false AND author = "#{@author.id}"),
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).twice.returns(results)
    AuthorsController.any_instance.stubs(:pagy).returns([ pagy, results ])

    get author_path(id: @author.id, q: "ruby"), as: :html
    assert_response :ok
    assert_includes response.body, book.title

    get author_path(id: @author.id, q: "ruby"), as: :turbo_stream
    assert_response :ok
    assert_includes response.body, book.title
  end

  test "passes search limits through the author book query" do
    results = [ create(:book, author: @author) ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Book.stubs(:pagy_search).returns(results)
    controller = AuthorsController.new
    controller.expects(:pagy).with(
      :meilisearch,
      results,
      limit: 1000
    ).returns([ pagy, results ])
    AuthorsController.stubs(:new).returns(controller)

    get author_path(id: @author.id, q: "ruby", limit: 1500)
  end

  test "lists authors with HTML, Turbo Stream, JSON, and pagination" do
    create(:author, name: "A Author", hidden: false)
    create(:author, name: "Z Author", hidden: false)
    create(:author, name: "Hidden Author", hidden: true)

    get authors_path, as: :json
    json = JSON.parse(response.body)
    assert_equal [ "A Author", "Test Author", "Z Author" ], json.map { |record| record.fetch("name") }
    assert_equal %w[id name], json.first.keys.sort
    assert_includes response.headers["Cache-Control"], "public"

    get authors_path, as: :html
    assert_response :ok
    refute_includes response.body, "Hidden Author"

    get authors_path, as: :turbo_stream
    assert_response :ok
    assert_includes response.body, 'target="results_list_1"'

    create_list(:author, 25, hidden: false)
    get authors_path(page: 2), as: :turbo_stream
    assert_includes response.body, 'target="results_list_2"'
  end

  test "searches authors and applies the configured limit" do
    first = create(:author, name: "John Doe", hidden: false)
    second = create(:author, name: "Jane Smith", hidden: false)
    results = [ first, second ]
    pagy = Pagy::Offset.new(count: 2, page: 1)

    Author.expects(:pagy_search).with(
      "john",
      filter: "hidden = false",
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ).returns(results)
    AuthorsController.any_instance.stubs(:pagy).returns([ pagy, results ])

    get authors_path(q: "john"), as: :html

    assert_response :ok
    assert_includes response.body, first.name
    assert_includes response.body, second.name
  end

  test "accepts an explicit limit for a searched author list" do
    results = [ @author ]
    pagy = Pagy::Offset.new(count: 1, page: 1)
    Author.stubs(:pagy_search).returns(results)
    controller = AuthorsController.new
    controller.expects(:pagy).with(:meilisearch, results, limit: 50).returns([ pagy, results ])
    AuthorsController.stubs(:new).returns(controller)

    get authors_path(q: "author", limit: 50)

    assert_response :ok
  end

  test "accepts an explicit limit for a regular author list" do
    get authors_path(limit: 50)

    assert_response :ok
  end

  test "records and suppresses search clicks for author pages" do
    user = create(:user)
    search_query = SearchQuery.create!(query: "author", refinements: { author: @author.id }, user:)
    sign_in user

    assert_difference("SearchClick.count", 1) do
      get author_path(id: @author.id, qid: search_query.id, i: "3")
    end
    click = SearchClick.last
    assert_equal [ search_query.id, @author.id, 3 ], [ click.search_query_id, click.result_id, click.index ]

    assert_difference("SearchClick.count", 1) do
      get author_path(id: @author.id, qid: search_query.id)
    end
    assert_equal(-1, SearchClick.last.index)

    assert_no_difference("SearchClick.count") do
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).returns(nil)
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).with("X-Sec-Purpose").returns("prefetch")
      get author_path(id: @author.id, qid: search_query.id, i: "3")
    end
  end

  test "skips the click when the controller receives a prefetch request" do
    controller = AuthorsController.new
    controller.stubs(:params).returns(ActionController::Parameters.new(qid: "query", i: "3"))
    request = mock("request")
    request.stubs(:headers).returns({ "X-Sec-Purpose" => "prefetch" })
    controller.stubs(:request).returns(request)
    controller.stubs(:search_or_list_author_books).returns([ Pagy::Offset.new(count: 0, page: 1), [] ])
    controller.stubs(:respond_to)
    assert controller.params[:qid].present?
    assert_equal "prefetch", controller.request.headers["X-Sec-Purpose"]

    assert_no_difference("SearchClick.count") { controller.show }
  end
end
