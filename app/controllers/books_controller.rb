class BooksController < ApplicationController
  before_action :set_book, only: [ :show, :search ]

  def index
    @pagy, @books = search_or_list

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "results_list_#{@pagy.page}",
          Components::BooksList.new(books: @books, pagy: @pagy)
        )
      end

      format.html { render Views::Books::Index.new(books: @books, pagy: @pagy) }
      format.json
    end
  end

  def show
    if params[:qid].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:i].presence&.to_i || -1, search_query_id: params[:qid], result: @book)
    end

    first_page = @book.pages.first

    redirect_to book_file_page_path(@book.id, first_page.file.id, first_page.number)
  end

  def search
    pagy, results = pagy_meilisearch(Page.pagy_search(
      params[:q],
      filter: %(book = "#{@book.id}" AND (hidden = false OR hidden NOT EXISTS)),
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ))

    search_query_id = params[:qid]
    if results.present? && params[:qid].blank? && request.headers["X-Sec-Purpose"] != "prefetch"
      search_query_id = SearchQuery.create(query: params[:q], refinements: { book: @book.id }, user: current_user).id
    end

    render turbo_stream: [
      turbo_stream.replace("results_count", Components::SearchResultsCount.new(count: pagy.count, class: "py-2")),
      turbo_stream.replace(
        "results_list_#{pagy.page}",
        Components::SearchBookResultsList.new(book: @book, results:, pagy:, search_query_id:)
      )
    ]
  end

  private

  def set_book = @book = Book.find(params[:book_id])

  def search_or_list
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: "hidden = false",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(Book.where(hidden: false).order(:title), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end
end
