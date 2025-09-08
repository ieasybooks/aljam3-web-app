class Api::V1::LibrariesController < Api::V1::BaseController
  def index = @libraries = Library.all

  def show = @library = Library.find(params[:id])
end
