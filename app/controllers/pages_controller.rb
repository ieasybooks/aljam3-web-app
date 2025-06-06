class PagesController < ApplicationController
  before_action :set_page, only: :show

  def show
    render Views::Pages::Show.new(page: @page)
  end

  private

  def set_page = @page = Page.find(params[:id])
end
