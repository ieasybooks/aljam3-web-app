# frozen_string_literal: true

class Components::SearchResultsList < Components::Base
  def initialize(results:, pagy:)
    @results = results
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, current_page do
      div(
        class: [
          "mt-2 space-y-4",
          ("mt-4" if current_page > 1)
        ]
      ) do
        @results.each_with_index do |result, index|
          case result
          when Book
            SearchBookCard(book: result)
          when Page
            SearchPageCard(page: result)
          end

          if (index + 1) == (results_count - 5) && next_page
            turbo_frame_tag :next_page, src: root_path(
              query: params[:query],
              refinements: {
                search_scope: params.dig(:refinements, :search_scope),
                library: params.dig(:refinements, :library),
                category: params.dig(:refinements, :category)
              },
              page: next_page
            ), loading: :lazy
          end
        end
      end
    end
  end

  private

  def current_page = @pagy&.page || (params[:page] || 1).to_i

  def next_page
    return @pagy.next if @pagy

    @results.metadata["estimatedTotalHits"] > current_page * Pagy::DEFAULT[:limit] ? current_page + 1 : nil
  end

  def results_count = @results.respond_to?(:hits) ? @results.hits.size : @results.size
end
