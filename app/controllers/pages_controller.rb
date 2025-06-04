class PagesController < ApplicationController
  def home = render Views::Pages::Home.new(results: search)

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
      Book.search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>")
    when "content"
      Page.search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>")
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
