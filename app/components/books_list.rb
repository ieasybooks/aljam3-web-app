class Components::BooksList < Components::Base
  def initialize(books:, pagy:)
    @books = books
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "space-y-4") do
        @books.each_with_index do |book, index|
          BookCard(book:)

          if (index + 1) == (@books.size - 5) && @pagy.next
            turbo_frame_tag :next_page, src: books_path(q: params[:q], page: @pagy.next, format: :turbo_stream), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, @pagy.next if @pagy.next
      end
    end
  end
end
