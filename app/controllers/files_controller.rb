class FilesController < ApplicationController
  before_action :set_file, only: :show

  def show = redirect_to book_file_page_path(@file.book.id, @file.id, @file.pages.first.number)

  private

  def set_file = @file = BookFile.find(params[:file_id])
end
