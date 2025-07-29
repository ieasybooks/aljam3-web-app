class Components::AuthorsList < Components::Base
  def initialize(authors:, pagy:)
    @authors = authors
    @pagy = pagy
  end

  def view_template
    turbo_frame_tag :results_list, @pagy.page do
      div(class: "space-y-4") do
        @authors.each_with_index do |author, index|
          AuthorCard(author: author)

          if (index + 1) == (@authors.size - 5) && @pagy.next
            turbo_frame_tag :next_page, src: authors_path(q: params[:q], page: @pagy.next, format: :turbo_stream), loading: :lazy
          end
        end

        turbo_frame_tag :results_list, @pagy.next if @pagy.next
      end
    end
  end
end
