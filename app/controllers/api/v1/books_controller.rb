class Api::V1::BooksController < Api::V1::BaseController
  include BooksSearching

  def index
    @pagy, @books = search_or_list_books
  end

  def show = @book = Book.where(hidden: false).find(params[:id])
end
