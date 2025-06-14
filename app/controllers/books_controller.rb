class BooksController < ApplicationController
  before_action :set_book, only: :show

  def show
    first_page = @book.pages.first

    redirect_to book_file_page_path(@book, first_page.file, first_page.number)
  end

  private

  def set_book = @book = Book.find(params[:id])
end
