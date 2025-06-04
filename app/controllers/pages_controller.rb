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
          Book => { q: query, filter: },
          Page => { q: query, filter: }
        }
      )
    when "title"
      Book.search(query, filter:)
    when "content"
      Page.search(query, filter:)
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
