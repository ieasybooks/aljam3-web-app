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

        if next_page
          turbo_frame_tag :results_list, next_page do
            div(class: "flex justify-center mt-4") { loading_spinner }
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

  def loading_spinner
    svg(class: "size-5 animate-spin", fill: "none", viewbox: "0 0 24 24") do |s|
      s.circle(class: "opacity-25", cx: "12", cy: "12", r: "10", stroke: "currentColor", stroke_width: "4")
      s.path(class: "opacity-75", fill: "currentColor", d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z")
    end
  end
end
