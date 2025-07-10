# frozen_string_literal: true

class Components::SearchBookResultsList < Components::Base
  def initialize(book:, results:, pagy:)
    @book = book
    @results = results
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "mt-4 space-y-4") do
        @results.each_with_index do |result, index|
          SearchPageCard(page: result)

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
