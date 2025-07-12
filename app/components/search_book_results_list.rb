# frozen_string_literal: true

class Components::SearchBookResultsList < Components::Base
  def initialize(book:, results:, pagy:, search_query:)
    @book = book
    @results = results
    @pagy = pagy
    @search_query = search_query
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "mt-4 space-y-4") do
        @results.each_with_index do |result, index|
          SearchPageCard(page: result, index: index + (@pagy.page - 1) * 20, search_query: @search_query)

          if (index + 1) == (@results.size - 5) && @pagy.next
            turbo_frame_tag :next_page, src: book_search_path(
              @book,
              query: params[:query],
              page: @pagy.next
            ), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, @pagy.next if @pagy.next
      end
    end
  end
end
