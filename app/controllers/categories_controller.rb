class CategoriesController < ApplicationController
  before_action :set_category, only: :show

  def index
    @categories = Category.order(:name)

    render Views::Categories::Index.new(categories: @categories)
  end

  def show
    @pagy, @books = pagy(@category.books)

    if @pagy.page == 1
      render Views::Categories::Show.new(category: @category, books: @books, pagy: @pagy)
    else
      render turbo_stream: turbo_stream.replace(
        "results_list_#{@pagy.page}",
        Components::CategoryBooksList.new(category: @category, books: @books, pagy: @pagy)
      )
    end
  end

  private

  def set_category = @category = Category.find(params[:id])
end
