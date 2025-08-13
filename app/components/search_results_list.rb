# frozen_string_literal: true

class Components::SearchResultsList < Components::Base
  def initialize(search_results:, search_query_id:, model:)
    @search_results = search_results
    @search_query_id = search_query_id
    @model = model
  end

  def view_template
    turbo_frame_tag "#{@model}_results_list", current_page do
      div(
        class: [
          "mt-2 space-y-4",
          ("mt-4" if current_page > 1)
        ]
      ) do
        @search_results.results.each_with_index do |result, index|
          case @model
          when "page"
            SearchPageCard(page: result, index: index + (current_page - 1) * 20, search_query_id: @search_query_id)
          when "book"
            SearchBookCard(book: result, index: index + (current_page - 1) * 20, search_query_id: @search_query_id)
          when "author"
            SearchAuthorCard(author: result, index: index + (current_page - 1) * 20, search_query_id: @search_query_id)
          end

          if (index + 1) == (results_count - 5) && next_page
            turbo_frame_tag :next_page, src: root_path(
              q: params[:q],
              m: @model,
              l: params.dig(:l),
              c: params.dig(:c),
              a: params.dig(:a),
              page: next_page,
              qid: @search_query_id,
            ), loading: :lazy
          end
        end

        turbo_frame_tag "#{@model}_results_list", next_page if next_page
      end
    end
  end

  private

  def current_page = @search_results.pagy.page
  def next_page = @search_results.pagy.next
  def results_count = @search_results.results.size
end
