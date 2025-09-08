class Api::V1::FilesController < Api::V1::BaseController
  before_action :set_book
  before_action :set_file, only: %i[ show ]

  def index = @files = @book.files

  def show
    @pagy, @pages = list_file_pages if params[:expand]&.include?("pages")
  end

  private

  def set_book = @book = Book.where(hidden: false).find(params[:book_id])
  def set_file = @file = @book.files.find(params[:id])
  def list_file_pages = pagy(@file.pages.order(:number), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
end
