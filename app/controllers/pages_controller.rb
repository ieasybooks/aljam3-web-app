class PagesController < ApplicationController
  before_action :set_page, :check_hidden

  def show
    if params[:qid].present? && request.headers["X-Sec-Purpose"] != "prefetch"
      SearchClick.create(index: params[:i].presence&.to_i || -1, search_query_id: params[:qid], result: @page)
    end

    respond_to do |format|
      format.html { render Views::Pages::Show.new(page: @page) }

      format.turbo_stream do
        if @page.content.blank?
          render turbo_stream: turbo_stream.update(
            "txt-content",
            Components::TxtMessage.new(variant: :info, text: t("pages.show.empty_page"))
          )
        else
          render turbo_stream: turbo_stream.update("txt-content", helpers.simple_format(@page.content))
        end
      end
    end
  end

  private

  def set_page = @page = Page.find_by(book_file_id: params[:file_id], number: params[:page_number])

  def check_hidden
    redirect_to root_path if @page.hidden
  end
end
