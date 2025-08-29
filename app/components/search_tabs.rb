# frozen_string_literal: true

class Components::SearchTabs < Components::Base
  def initialize(tabs_search_results:, search_query_id:, libraries:, categories:)
    @tabs_search_results = tabs_search_results
    @search_query_id = search_query_id
    @libraries = libraries
    @categories = categories
  end

  def view_template
    Tabs(default_value: "titles", class: "pt-2") do
      div(class: "flex gap-2 items-center") do
        TabsList(class: "") do
          TabsTrigger(value: "titles", icon: -> { Hero::BookOpen(class: "inline size-4 me-1") }) { t(".titles") }
          TabsTrigger(value: "pages", icon: -> { Hero::DocumentMagnifyingGlass(class: "inline size-4 me-1") }) { t(".pages") }
          TabsTrigger(value: "authors", icon: -> { Hero::User(class: "inline size-4 me-1") }) { t(".authors") }
        end
        SearchRefinementsSheet(libraries: @libraries, categories: @categories, trigger_size: :md, icon_size: "size-4.5")
      end

      div(class: "my-6")
      TabsContent(value: "pages") do
        if @tabs_search_results.pages.results.any?
          SearchResultsCount(count: @tabs_search_results.pages.pagy.count)
          SearchResultsList(
            search_results: @tabs_search_results.pages,
            search_query_id: @search_query_id,
            model: "page"
          )
        else
          SearchNoResultsFound()
        end
      end

      TabsContent(value: "titles") do
        if @tabs_search_results.books.results.any?
          SearchResultsCount(count: @tabs_search_results.books.pagy.count)
          SearchResultsList(
            search_results: @tabs_search_results.books,
            search_query_id: @search_query_id,
            model: "book"
          )
        else
          SearchNoResultsFound()
        end
      end

      TabsContent(value: "authors") do
        if @tabs_search_results.authors.results.any?
          SearchResultsCount(count: @tabs_search_results.authors.pagy.count)
          SearchResultsList(
            search_results: @tabs_search_results.authors,
            search_query_id: @search_query_id,
            model: "author"
          )
        else
          SearchNoResultsFound()
        end
      end
    end
  end
end
