class BooksController < ApplicationController
  before_action :set_book, only: :show

  def show = redirect_to book_page_path(@book, @book.first_page)

  private

  def set_book = @book = Book.find(params[:id])
end
