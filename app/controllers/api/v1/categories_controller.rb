class Api::V1::CategoriesController < Api::V1::BaseController
  include CategoriesSearching

  def index = @categories = Category.order(:name)

  def show
    @category = Category.find(params[:id])
    @pagy, @books = search_or_list_category_books if params[:expand]&.include?("books")
  end
end
