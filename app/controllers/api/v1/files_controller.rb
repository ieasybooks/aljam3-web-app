class Api::V1::FilesController < Api::V1::BaseController
  before_action :set_file

  def show
    @pagy, @pages = list_file_pages if params[:expand]&.include?("pages")
  end

  private

  def set_file
    @file = BookFile.find(params[:id])

    raise ActiveRecord::RecordNotFound if @file.book.hidden
  end

  def list_file_pages = pagy(@file.pages.order(:number), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
end
