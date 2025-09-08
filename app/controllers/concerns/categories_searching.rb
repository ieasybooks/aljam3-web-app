module CategoriesSearching
  extend ActiveSupport::Concern

  def search_or_list_category_books
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: %((hidden = false OR hidden NOT EXISTS) AND category = "#{@category.id}"),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(@category.books.where(hidden: false).order(:title), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end
end
