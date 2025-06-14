class FilesController < ApplicationController
  before_action :set_file, only: :show

  def show = redirect_to book_file_page_path(@file.book, @file, @file.pages.first)

  private

  def set_file = @file = BookFile.find(params[:id])
end
