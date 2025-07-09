class BooksController < ApplicationController
  before_action :set_book, only: :show

  def show
    first_page = @book.pages.first

    redirect_to book_file_page_path(@book.id, first_page.file.id, first_page.number)
  end

  private

  def set_book = @book = Book.find(params[:book_id])
end
