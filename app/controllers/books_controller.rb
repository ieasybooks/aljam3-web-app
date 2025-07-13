class BooksController < ApplicationController
  before_action :set_book

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
      filter: %(book = "#{@book.id}"),
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ))

    search_query_id = params[:qid]
    if results.present? && params[:qid].blank? && request.headers["X-Sec-Purpose"] != "prefetch"
      search_query_id = SearchQuery.create(query: params[:q], refinements: { book: @book.id }, user: current_user).id
    end

    render turbo_stream: turbo_stream.replace(
      params[:page].blank? ? "results_list" : "results_list_#{params[:page]}",
      Components::SearchBookResultsList.new(book: @book, results:, pagy:, search_query_id:)
    )
  end

  private

  def set_book = @book = Book.find(params[:book_id])
end
