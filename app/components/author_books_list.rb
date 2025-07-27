class Components::AuthorBooksList < Components::Base
  def initialize(author:, books:, pagy:)
    @author = author
    @books = books
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "space-y-4") do
        @books.each_with_index do |book, index|
          BookCard(book:, show_author: false)

          if (index + 1) == (@books.size - 5) && @pagy.next
            turbo_frame_tag :next_page, src: author_path(@author.id, page: @pagy.next), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, @pagy.next if @pagy.next
      end
    end
  end
end
