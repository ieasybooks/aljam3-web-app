module AuthorsSearching
  extend ActiveSupport::Concern

  def search_or_list_authors
    if params[:q].present?
      pagy_meilisearch(
        Author.pagy_search(
          params[:q],
          filter: "hidden = false",
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(Author.where(hidden: false).order(:name), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end

  def search_or_list_author_books
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: %(hidden = false AND author = "#{@author.id}"),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(@author.books.where(hidden: false).order(:title), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end
end
