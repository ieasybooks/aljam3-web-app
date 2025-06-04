class PagesController < ApplicationController
  def home
    pagy, results = search

    render Views::Pages::Home.new(results:, pagy:)
  end

  private

  def search
    query = params[:query]

    return nil if query.blank?

    case params.dig(:refinements, :search_scope)
    when "title-and-content"
      Meilisearch::Rails.federated_search(
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
        }
      )
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
