class PagesController < ApplicationController
  def home
    results = (search if params[:query].present?)

    render Views::Pages::Home.new(results:)
  end

  private

  def search
    query = params[:query]
    scope = params[:refinements][:search_scope]

    if scope == "title-and-content"
      Meilisearch::Rails.federated_search(
        queries: {
          Book => { q: query },
          Page => { q: query }
        }
      )
    elsif scope == "title"
      Book.search(query)
    elsif scope == "content"
      Page.search(query)
    end
  end
end
