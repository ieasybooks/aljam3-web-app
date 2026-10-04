module BooksSearching
  extend ActiveSupport::Concern

  def search_or_list_books(filters: {})
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: ([ "hidden = false" ] + filters.map { |key, id| "#{key} = #{id}" }).join(" AND "),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(Book.where(hidden: false, **filters.transform_keys { |key| "#{key}_id" }).order(:title, :id), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end
end
