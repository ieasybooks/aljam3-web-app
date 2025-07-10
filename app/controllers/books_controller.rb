class BooksController < ApplicationController
  before_action :set_book

  def show
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

    render turbo_stream: turbo_stream.replace(
      params[:page].blank? ? "results_list" : "results_list_#{params[:page]}",
      Components::SearchBookResultsList.new(book: @book, results:, pagy:)
    )
  end

  private

  def set_book = @book = Book.find(params[:book_id])
end
