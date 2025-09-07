class Api::V1::AuthorsController < Api::V1::BaseController
  include AuthorsSearching

  def index
    @pagy, @authors = search_or_list_authors
  end

  def show
    @author = Author.where(hidden: false).find(params[:id])
    @pagy, @books = search_or_list_author_books
  end
end
