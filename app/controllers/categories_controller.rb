class CategoriesController < ApplicationController
  before_action :set_category, only: :show

  def index = render Views::Categories::Index.new(categories: Category.order(:name))

  def show
    pagy, books = search_or_list

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "results_list_#{pagy.page}",
          Components::CategoryBooksList.new(category: @category, books:, pagy:)
        )
      end

      format.html do
        render Views::Categories::Show.new(category: @category, books:, pagy:)
      end
    end
  end

  private

  def set_category = @category = Category.find(params[:id])

  def search_or_list
    if params[:q].present?
      pagy_meilisearch(Book.pagy_search(
        params[:q],
        filter: %((hidden = false OR hidden NOT EXISTS) AND category = "#{@category.id}"),
        highlight_pre_tag: "<mark>",
        highlight_post_tag: "</mark>"
      ))
    else
      pagy(@category.books.where(hidden: false).order(:title))
    end
  end
end
