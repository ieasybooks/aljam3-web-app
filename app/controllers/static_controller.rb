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
    results = search

    if results.present? && params[:qid].blank? && request.headers["X-Sec-Purpose"] != "prefetch"
      search_query_id = SearchQuery.create(
        query: params[:q],
        refinements: {
          library: params.dig(:l),
          category: params.dig(:c),
          author: params.dig(:a)
        }.compact,
        user: current_user
      ).id
    else
      search_query_id = params[:qid]
    end

    if valid_model?
      render turbo_stream: turbo_stream.replace(
        "#{params[:m]}_results_list_#{params[:page]}",
        Components::SearchResultsList.new(search_results: results, search_query_id:, model: params[:m])
      )
    else
      render Views::Static::Home.new(tabs_search_results: results, search_query_id:, carousels_books_ids:, libraries:, categories:)
    end
  end

  private

  def search
    query = params[:q]

    return nil if query.blank?

    if valid_model?
      model = params[:m].classify.constantize

      pagy, results = pagy_meilisearch(model.pagy_search(query, filter: filter(model), highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))

      SearchResults.new(pagy:, results:)
    else
      page_pagy, page_results = pagy_meilisearch(Page.pagy_search(query, filter: filter(Page), highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
      book_pagy, book_results = pagy_meilisearch(Book.pagy_search(query, filter: filter(Book), highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))
      author_pagy, author_results = pagy_meilisearch(Author.pagy_search(query, filter: filter(Author), highlight_pre_tag: "<mark>", highlight_post_tag: "</mark>"))

      TabsSearchResults.new(
        pages: SearchResults.new(pagy: page_pagy, results: page_results),
        books: SearchResults.new(pagy: book_pagy, results: book_results),
        authors: SearchResults.new(pagy: author_pagy, results: author_results)
      )
    end
  end

  def filter(model)
    library = params.dig(:l)
    category = params.dig(:c)
    author = params.dig(:a)

    expression = [ "(hidden = false OR hidden NOT EXISTS)" ]

    unless model == Author
      expression << %(library = "#{library}") if library.present? && library != "a"
      expression << %(category = "#{category}") if category.present? && category != "a"
      expression << %(author = "#{author}") if author.present? && author != "a"
    end

    expression.join(" AND ")
  end

  def carousels_books_ids
    proc do
      {
        faith:    Book.where(category_id: CATEGORY_IDS[:faith], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        quran:    Book.where(category_id: CATEGORY_IDS[:quran], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        hadith:   Book.where(category_id: CATEGORY_IDS[:hadith], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        fiqh:     Book.where(category_id: CATEGORY_IDS[:fiqh], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        history:  Book.where(category_id: CATEGORY_IDS[:history], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        language: Book.where(category_id: CATEGORY_IDS[:language], hidden: false).order("RANDOM()").limit(10).pluck(:id),
        other:    Book.where(category_id: CATEGORY_IDS[:other], hidden: false).order("RANDOM()").limit(10).pluck(:id)
      }
    end
  end

  def libraries = proc { Library.all.order(:id).pluck(:id, :name) }
  def categories = proc { Category.order(:name).pluck(:id, :name, :books_count) }

  def valid_model? = params[:m].present? && [ "page", "book", "author" ].include?(params[:m])
end
