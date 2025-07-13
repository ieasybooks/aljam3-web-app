class StaticController < ApplicationController
  CATEGORY_IDS = {
    faith: [ 24, 34, 35, 36, 37, 38, 39, 40, 54 ],
    quran: [ 1, 17, 20, 21, 22, 88, 101 ],
    hadith: [ 3, 26, 47, 62, 67, 74, 81, 87, 91, 100, 102, 104, 105 ],
    fiqh: [ 2, 4, 43, 52, 53, 55, 56, 57, 58, 59, 90 ],
    history: [ 9, 14, 15, 16, 18, 44, 76, 77, 78, 79, 80 ],
    language: [ 5, 31, 46, 51, 63, 68, 69, 73 ],
    other: [ 6, 7, 8, 10, 11, 12, 13, 19, 23, 25, 27, 28, 29, 30, 32, 33, 41, 42, 45, 48, 49, 50, 60, 61, 64, 65, 66, 70, 71, 72, 75, 82, 83, 84, 85, 86, 89, 92, 93, 94, 95, 96, 97, 98, 99, 103 ]
  }

  def home
    pagy, results = search

    if results.present? && params[:qid].blank? && request.headers["X-Sec-Purpose"] != "prefetch"
      search_query_id = SearchQuery.create(
        query: params[:q],
        refinements: {
          search_scope: params.dig(:s),
          library: params.dig(:l),
          category: params.dig(:c),
          author: params.dig(:a)
        }.compact,
        user: current_user
      ).id
    else
      search_query_id = params[:qid]
    end

    if params[:page].presence.to_i > 1
      render turbo_stream: turbo_stream.replace(
        "results_list_#{params[:page]}",
        Components::SearchResultsList.new(results:, pagy:, search_query_id:)
      )
    else
      render Views::Static::Home.new(results:, pagy:, search_query_id:, carousels_books_ids:, libraries:, categories:)
    end
  end

  private

  def search
    query = params[:q]

    return nil if query.blank?

    case params.dig(:s)
    when "b"
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
    when "t"
      pagy_meilisearch(Book.pagy_search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
    when "c"
      pagy_meilisearch(Page.pagy_search(query, filter:, highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
    end
  end

  def filter
    library = params.dig(:l)
    category = params.dig(:c)
    author = params.dig(:a)

    expression = []
    expression << "library = \"#{library}\"" if library.present? && library != "a"
    expression << "category = \"#{category}\"" if category.present? && category != "a"
    expression << "author = \"#{author}\"" if author.present? && author != "a"

    expression.any? ? expression.join(" AND ") : nil
  end

  def carousels_books_ids
    proc do
      {
        faith:    Book.where(category_id: CATEGORY_IDS[:faith]).order("RANDOM()").limit(10).pluck(:id),
        quran:    Book.where(category_id: CATEGORY_IDS[:quran]).order("RANDOM()").limit(10).pluck(:id),
        hadith:   Book.where(category_id: CATEGORY_IDS[:hadith]).order("RANDOM()").limit(10).pluck(:id),
        fiqh:     Book.where(category_id: CATEGORY_IDS[:fiqh]).order("RANDOM()").limit(10).pluck(:id),
        history:  Book.where(category_id: CATEGORY_IDS[:history]).order("RANDOM()").limit(10).pluck(:id),
        language: Book.where(category_id: CATEGORY_IDS[:language]).order("RANDOM()").limit(10).pluck(:id),
        other:    Book.where(category_id: CATEGORY_IDS[:other]).order("RANDOM()").limit(10).pluck(:id)
      }
    end
  end

  def libraries = proc { Library.all.order(:id).pluck(:id, :name) }
  def categories = proc { Category.order(:name).pluck(:id, :name, :books_count) }
end
