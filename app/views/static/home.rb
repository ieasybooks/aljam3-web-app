class Views::Static::Home < Views::Base
  def initialize(results:, pagy:, carousel_books_ids:, categories:, libraries:)
    @results = results
    @pagy = pagy
    @carousel_books_ids = carousel_books_ids
    @categories = categories
    @libraries = libraries
  end

  def page_title = t(".title")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      header if @results.nil?

      SearchForm(libraries: @libraries, categories: @categories)

      if @results.nil?
        carousel
      else
        @results.any? ? SearchResultsList(results: @results, pagy: @pagy) : SearchNoResultsFound()
      end
    end
  end

  private

  def header
    div(class: "flex justify-center pb-6 sm:pb-4") do
      div(class: "flex max-sm:flex-col items-center gap-4 sm:gap-8") do
        Aljam3Logo(class: "size-50 text-primary flex-shrink-0")

        div(class: "font-[Cairo] w-full max-sm:text-center sm:w-96") do
          p(class: "text-4xl sm:text-5xl pb-4 sm:pb-6") { t(".one_site") }

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

  def carousel
    low_level_cache("books_carousel", expires_in: 1.minute) do
      Heading(level: 2, class: "my-4 mb-5") { t(".discover_books") }

      Carousel(class: "sm:border-r sm:border-l max-sm:mx-10", options: { direction: }) do
        CarouselContent(class: "max-sm:group-[.is-horizontal]:-ms-2") do
          Book.where(id: @carousel_books_ids).each do |book|
            CarouselItem(class: "md:basis-1/2 lg:basis-1/4 max-sm:group-[.is-horizontal]:ps-2") do
              div(class: "pb-0.5") { CarouselBookCard(book:) }
            end
          end
        end

        CarouselPrevious(class: "group-[.is-horizontal]:-left-10 sm:group-[.is-horizontal]:left-4")
        CarouselNext(class: "group-[.is-horizontal]:-right-10 sm:group-[.is-horizontal]:right-4")
      end
    end
  end
end
