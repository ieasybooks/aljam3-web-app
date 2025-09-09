class Api::V1::LibrariesController < Api::V1::BaseController
  def index = @libraries = Library.all

  def show
    @library = Library.find(params[:id])
    @pagy, @books = search_or_list_library_books if params[:expand]&.include?("books")
  end

  private

  def search_or_list_library_books
    if params[:q].present?
      pagy_meilisearch(
        Book.pagy_search(
          params[:q],
          filter: %(hidden = false AND library = "#{@library.id}"),
          highlight_pre_tag: "<mark>",
          highlight_post_tag: "</mark>"
        ),
        limit: [ params[:limit].presence&.to_i || 20, 1000 ].min
      )
    else
      pagy(@library.books.order(created_at: :desc), limit: [ params[:limit].presence&.to_i || 20, 1000 ].min)
    end
  end
end
