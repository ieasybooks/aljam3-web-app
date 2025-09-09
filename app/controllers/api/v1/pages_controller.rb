class Api::V1::PagesController < Api::V1::BaseController
  before_action :set_file

  def index = @pages = @file.pages.order(:number)

  private

  def set_file
    @file = BookFile.find(params[:file_id])

    raise ActiveRecord::RecordNotFound if @file.book.hidden
  end
end
