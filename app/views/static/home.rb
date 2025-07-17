class Views::Static::Home < Views::Base
  def initialize(results:, pagy:, search_query_id:, carousels_books_ids:, categories:, libraries:)
    @results = results
    @pagy = pagy
    @search_query_id = search_query_id
    @carousels_books_ids = carousels_books_ids
    @categories = categories
    @libraries = libraries
  end

  def page_title
    if @results.nil?
      t(".title")
    else
      t(".results_title", query: params[:q])
    end
  end

  def description = t(".description")
  def keywords = t(".keywords")
  def no_banner = @results.present?

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      header if @results.nil?

      SearchForm(libraries: @libraries, categories: @categories)

      if @results.nil?
        cache expires_in: 1.hour do
          div(class: "mb-10") do
            search_examples
            carousels
            categories
          end
        end
      else
        @results.any? ? SearchResultsList(results: @results, pagy: @pagy, search_query_id: @search_query_id) : SearchNoResultsFound()
      end
    end
  end

  private

  def header
    div(class: "flex justify-center pb-6 sm:pb-4") do
      div(class: "flex max-sm:flex-col items-center gap-4 sm:gap-8") do
        Aljam3Logo(class: "size-50 text-primary flex-shrink-0")

        div(class: "font-[Cairo] w-full max-sm:text-center sm:w-96") do
          p(class: "text-4xl sm:text-5xl pb-4 sm:pb-6") { t(".one_place") }

          p(
            class: "text-4xl sm:text-5xl font-bold",
            data: {
              controller: "text-rotation",
              text_rotation_strings_value: [
                t(".three_libraries"),
                t(".hundred_categories"),
                t(".thirty_four_authors"),
                t(".sixty_three_books"),
                t(".thirty_seven_million_pages")
              ].to_json
            }
          ) { t(".three_libraries") }
        end
      end
    end
  end

  def search_examples
    div(class: "mt-2 horizontal-scroll-indicators") do
      div(class: "flex gap-2 overflow-x-auto no-scrollbar") do
        t(".examples").each do |example|
          a(href: root_path(q: example, s: "b")) do
            Badge(variant: :primary, class: "cursor-pointer whitespace-nowrap") { example }
          end
        end
      end
    end
  end

  def carousels
    div(class: "py-16 sm:py-20 flex items-center") do
      div(class: "flex-1 border-t border-border")
      Text(size: "9", class: "px-4 text-center font-[Cairo] max-sm:text-3xl") { t(".discover_books") }
      div(class: "flex-1 border-t border-border")
    end

    @carousels_books_ids.call.each_with_index do |(carousel_name, books_ids), index|
      Heading(
        level: 2,
        class: [
          "my-4 mb-5",
          ("mt-10" unless index.zero?)
        ]
      ) { t(".#{carousel_name}") }

      Carousel(class: "sm:border-r sm:border-l max-sm:mx-10", options: { direction: }) do
        CarouselContent(class: "max-sm:group-[.is-horizontal]:-ms-2") do
          Book.where(id: books_ids).each do |book|
            CarouselItem(class: "md:basis-1/2 lg:basis-1/4 max-sm:group-[.is-horizontal]:ps-2") do
              div(class: "pb-0.5") { BookCard(book:) }
            end
          end
        end

        CarouselPrevious(class: "group-[.is-horizontal]:-left-10 sm:group-[.is-horizontal]:left-4")
        CarouselNext(class: "group-[.is-horizontal]:-right-10 sm:group-[.is-horizontal]:right-4")
      end
    end
  end

  def categories
    div(class: "py-16 sm:py-20 flex items-center") do
      div(class: "flex-1 border-t border-border")
      Text(size: "9", class: "px-4 text-center font-[Cairo] max-sm:text-3xl") { t(".categories") }
      div(class: "flex-1 border-t border-border")
    end

    div(class: "flex justify-center") do
      Card(class: "w-full overflow-hidden") do
        CardContent(class: "p-0 max-h-96 overflow-y-auto") do
          @categories.call.each_with_index do |(id, name, count), index|
            Link(href: category_path(id:), class: "w-full px-3 py-5 border-b border-border rounded-none hover:bg-accent hover:no-underline") do
              div(class: "w-full flex justify-between") do
                Text(size: "4") { "#{index + 1}. #{name}" }
                Text(size: "4") { number_with_delimiter(count) }
              end
            end
          end
        end
      end
    end
  end
end
