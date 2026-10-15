require "test_helper"

class PagesTest < ApplicationTest
  setup do
    @page = create(:page)
    @search_query = SearchQuery.create!(query: "test query", refinements: { search_scope: "c" }, user: nil)
  end

  test "renders an HTML page" do
    get page_path_for(@page)

    assert_response :success
    assert_equal "text/html", response.media_type
  end

  test "records a search click with the requested index" do
    assert_difference("SearchClick.count", 1) do
      get page_path_for(@page, qid: @search_query.id, i: "5")
    end

    click = SearchClick.last
    assert_equal 5, click.index
    assert_equal @search_query.id, click.search_query_id
    assert_equal @page, click.result

    assert_difference("SearchClick.count", 1) do
      get page_path_for(@page, qid: @search_query.id)
    end
    assert_equal(-1, SearchClick.last.index)
  end

  test "does not record a prefetch or anonymous search click" do
    assert_no_difference("SearchClick.count") do
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).returns(nil)
      ActionDispatch::Http::Headers.any_instance.stubs(:[]).with("X-Sec-Purpose").returns("prefetch")
      get page_path_for(@page, qid: @search_query.id)
      get page_path_for(@page)
      get page_path_for(@page, qid: "")
    end
  end

  test "renders page content as a Turbo Stream" do
    @page.update!(content: "This is some page content.")

    get page_path_for(@page), as: :turbo_stream

    assert_response :success
    assert_includes response.body, '<turbo-stream action="update" target="txt-content">'
    assert_includes response.body, "<p>This is some page content.</p>"
  end

  test "renders an empty-page message" do
    @page.update_column(:content, "")

    get page_path_for(@page, locale: "en"), as: :turbo_stream

    assert_response :success
    assert_includes response.body, "Empty Page"
  end

  test "falls back to the last page for an out-of-range page number" do
    file = create(:book_file, :with_pages, pages_count: 3)
    last_page = file.pages.order(:number).last

    get page_path_for(last_page, page_number: last_page.number + 100)

    assert_response :success
    assert_includes response.body, last_page.content
  end

  test "redirects hidden pages to the root" do
    book = create(:book, :with_files, hidden: true)
    page = book.pages.first

    get page_path_for(page)

    assert_redirected_to root_path
  end

  test "increments book views for HTML and not Turbo Stream requests" do
    assert_difference -> { @page.file.book.reload.views_count }, 1 do
      get page_path_for(@page)
    end

    assert_no_changes -> { @page.file.book.reload.views_count } do
      get page_path_for(@page), as: :turbo_stream
    end
  end

  test "skips the click when the page request is a prefetch" do
    controller = PagesController.new
    controller.instance_variable_set(:@page, @page)
    controller.stubs(:params).returns(ActionController::Parameters.new(qid: "query", i: "3", page_number: @page.number.to_s))
    format = mock("format")
    format.stubs(:html?).returns(false)
    format.stubs(:turbo_stream?).returns(true)
    controller.stubs(:request).returns(mock(headers: { "X-Sec-Purpose" => "prefetch" }, format:))
    controller.stubs(:respond_to)

    assert_no_difference("SearchClick.count") { controller.show }
  end

  private

  def page_path_for(page, page_number: page.number, **params)
    book_file_page_path(book_id: page.file.book.id, file_id: page.file.id, page_number:, **params)
  end
end
