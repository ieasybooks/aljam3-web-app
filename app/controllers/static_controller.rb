class StaticController < ApplicationController
  def home
    pagy, results = search

    if params[:page].presence.to_i > 1
      render turbo_stream: turbo_stream.replace(
        "results_list_#{params[:page]}",
        Components::SearchResultsList.new(results:, pagy:)
      )
    else
      carousel_books = Book.where(id: Rails.cache.read("carousel_books_ids")).presence || Book.order("RANDOM()").limit(10)

      render Views::Static::Home.new(results:, pagy:, carousel_books:)
    end
  end

  private

  def search
    query = params[:query]

    return nil if query.blank?

    case params.dig(:refinements, :search_scope)
    when "title-and-content"
      [ nil, Meilisearch::Rails.federated_search(
        queries: {
          Book => {
            q: query,
            filter:,
            attributes_to_highlight: %i[title],
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          },
          Page => {
            q: query,
            filter:,
            attributes_to_highlight: %i[content],
            highlight_pre_tag: "<mark>",
            highlight_post_tag: "</mark>"
          }
        },
        federation: { offset: ((params[:page] || 1).to_i - 1) * 20 }
      ) ]
    when "title"
      pagy_meilisearch(Book.pagy_search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
    when "content"
      pagy_meilisearch(Page.pagy_search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
    end
  end

  def filter
    library = params.dig(:refinements, :library)
    category = params.dig(:refinements, :category)

    expression = []
    expression << "library = \"#{library}\"" if library.present? && library != "all-libraries"
    expression << "category = \"#{category}\"" if category.present? && category != "all-categories"

    expression.any? ? expression.join(" AND ") : nil
  end
end
