class Api::V1::BooksController < Api::V1::BaseController
  include BooksSearching

  def index
    @book_filters = book_filters
    @pagy, @books = search_or_list_books(filters: @book_filters)
  end

  def show
    @book = Book.where(hidden: false).find(params[:id])
    @files = @book.files if params[:expand]&.include?("files")
  end
  private

  def book_filters
    %w[library author category].each_with_object({}) do |key, filters|
      next unless params[key].present?

      value = params[key]
      unless value.is_a?(String) && value.match?(/\A[0-9]+\z/) && value.to_i.positive?
        raise ActionController::BadRequest, "#{key} must be a positive integer"
      end
      filters[key] = value.to_i
    end
  end
end
