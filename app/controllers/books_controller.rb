class BooksController < ApplicationController
  before_action :set_book

  def show
    if params[:search_query_id].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:index].presence&.to_i || -1, search_query_id: params[:search_query_id], result: @book)
    end

    first_page = @book.pages.first

    redirect_to book_file_page_path(@book.id, first_page.file.id, first_page.number)
  end

  def search
    pagy, results = pagy_meilisearch(Page.pagy_search(
      params[:query],
      filter: %(book = "#{@book.id}"),
      highlight_pre_tag: "<mark>",
      highlight_post_tag: "</mark>"
    ))

    search_query_id = params[:search_query_id]
    if results.present? && params[:search_query_id].blank? && request.headers["X-Sec-Purpose"] != "prefetch"
      search_query_id = SearchQuery.create(
        query: params[:query],
        refinements: { book: @book.id },
        user: current_user
      ).id
    end

    render turbo_stream: turbo_stream.replace(
      params[:page].blank? ? "results_list" : "results_list_#{params[:page]}",
      Components::SearchBookResultsList.new(book: @book, results:, pagy:, search_query_id:)
    )
  end

  private

  def set_book = @book = Book.find(params[:book_id])
end
