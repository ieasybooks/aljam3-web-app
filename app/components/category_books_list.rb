# frozen_string_literal: true

class Components::CategoryBooksList < Components::Base
  def initialize(category:, books:, pagy:)
    @category = category
    @books = books
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "space-y-4") do
        @books.each_with_index do |book, index|
          BookCard(book:, show_category: false)

          if (index + 1) == (@books.size - 5) && @pagy.next
            turbo_frame_tag :next_page, src: category_path(@category.id, q: params[:q], page: @pagy.next, format: :turbo_stream), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, @pagy.next if @pagy.next
      end
    end
  end
end
