class PagesController < ApplicationController
  before_action :set_page
  before_action :set_search_query

  def show
    if @search_query.present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:index].presence&.to_i || -1, search_query: @search_query, result: @page)
    end

    respond_to do |format|
      format.html { render Views::Pages::Show.new(page: @page) }
      format.turbo_stream { render turbo_stream: turbo_stream.update("txt-content", helpers.simple_format(@page.content)) }
    end
  end

  private

  def set_page = @page = Page.find_by(book_file_id: params[:file_id], number: params[:page_number])

  def set_search_query
    @search_query = nil

    if params[:search_query].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      @search_query = SearchQuery.find(params[:search_query])
    end
  end
end
