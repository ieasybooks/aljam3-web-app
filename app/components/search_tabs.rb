# frozen_string_literal: true

class Components::SearchTabs < Components::Base
  def initialize(tabs_search_results:, search_query_id:)
    @tabs_search_results = tabs_search_results
    @search_query_id = search_query_id
  end

  def view_template
    Tabs(default: "pages", class: "pt-2") do
      TabsList(class: "max-sm:w-full max-sm:grid max-sm:grid-cols-3") do
          TabsTrigger(value: "pages", class: "cursor-pointer flex items-center gap-1") do
            Lucide::File(class: "size-4 stroke-[1.5]")
            plain t(".pages")
          end
          TabsTrigger(value: "titles", class: "cursor-pointer flex items-center gap-1") do
            Hero::BookOpen(variant: :outline, class: "size-4")
            plain t(".titles")
          end
          TabsTrigger(value: "authors", class: "cursor-pointer flex items-center gap-1") do
            Hero::UserGroup(variant: :outline, class: "size-4")
            plain t(".authors")
          end
      end

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
