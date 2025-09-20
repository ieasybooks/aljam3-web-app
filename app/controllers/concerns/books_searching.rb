module BooksSearching
  extend ActiveSupport::Concern

  def search_or_list_books
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: search_filters,
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      base_query = Book.where(hidden: false)

      if params[:favorites] == "true" && user_signed_in?
        base_query = base_query.joins(:favorites).where(favorites: { user: current_user })
      end

      pagy(base_query.order(:title), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end

  private

  def search_filters
    filters = [ "hidden = false" ]

    # use favorites filter for search
    if params[:favorites] == "true" && user_signed_in?
      favorite_book_ids = current_user.favorites.pluck(:book_id)
      if favorite_book_ids.any?
        filters << "id IN [#{favorite_book_ids.join(', ')}]"
      else
        # If user has no favorites, return no results
        filters << "id IN [0]"
      end
    end

    filters.join(" AND ")
  end
end
