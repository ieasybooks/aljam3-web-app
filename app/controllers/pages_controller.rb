class PagesController < ApplicationController
  before_action :set_page

  def show
    if params[:qid].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:i].presence&.to_i || -1, search_query_id: params[:qid], result: @page)
    end

    respond_to do |format|
      format.html { render Views::Pages::Show.new(page: @page) }
      format.turbo_stream { render turbo_stream: turbo_stream.update("txt-content", helpers.simple_format(@page.content)) }
    end
  end

  private

  def set_page = @page = Page.find_by(book_file_id: params[:file_id], number: params[:page_number])
end
