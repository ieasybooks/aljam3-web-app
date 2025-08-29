class Views::Static::Home < Views::Base
  def initialize(tabs_search_results:, search_query_id:, carousels_books_ids:, categories:, libraries:)
    @tabs_search_results = tabs_search_results
    @search_query_id = search_query_id
    @carousels_books_ids = carousels_books_ids
    @categories = categories
    @libraries = libraries
  end

  def page_title
    if params[:q].present?
      t(".results_title", query: params[:q])
    elsif hotwire_native_app?
      t("aljam3")
    else
      t(".title")
    end
  end

  def description = t(".description")
  def keywords = t(".keywords")
  def no_banner = params[:q].present?

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      header if params[:q].blank?
      SearchForm(libraries: @libraries, categories: @categories)

      if params[:q].blank?
        cache [ I18n.locale, hotwire_native_app?, android_native_app?, ios_native_app? ], expires_in: 1.hour do
          div(class: "mb-10") do
            search_examples
            most_viewed_books
            books_by_category
            categories unless hotwire_native_app?
          end
        end
      else
          SearchTabs(tabs_search_results: @tabs_search_results, search_query_id: @search_query_id, libraries: @libraries, categories: @categories)
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

  def most_viewed_books
    div(class: "py-16 sm:py-20 flex items-center") do
      div(class: "flex-1 border-t border-border max-sm:-ms-4")
      Text(size: "9", class: "px-4 text-center font-[Cairo] max-sm:text-3xl") { t(".most_viewed") }
      div(class: "flex-1 border-t border-border max-sm:-me-4")
    end

    Carousel(class: "sm:border-r sm:border-l max-sm:-mx-4", options: { direction: }) do
      CarouselContent(class: "max-sm:group-[.is-horizontal]:-ms-2") do
        Book.most_viewed(10).each do |book|
          CarouselItem(class: "max-sm:basis-xs md:basis-1/2 lg:basis-1/4 max-sm:group-[.is-horizontal]:ps-2") do
            div(class: "pb-0.5") { BookCard(book:) }
          end
        end
      end

      CarouselPrevious(class: "max-sm:hidden sm:group-[.is-horizontal]:left-4")
      CarouselNext(class: "max-sm:hidden sm:group-[.is-horizontal]:right-4")
    end
  end

  def books_by_category
    div(class: "py-16 sm:py-20 flex items-center") do
      div(class: "flex-1 border-t border-border max-sm:-ms-4")
      Text(size: "9", class: "px-4 text-center font-[Cairo] max-sm:text-3xl") { t(".discover_books") }
      div(class: "flex-1 border-t border-border max-sm:-me-4")
    end

    @carousels_books_ids.call.each_with_index do |(carousel_name, books_ids), index|
      Heading(
        level: 2,
        class: [
          "my-4 mb-5",
          ("mt-10" unless index.zero?)
        ]
      ) { t(".#{carousel_name}") }

      Carousel(class: "sm:border-r sm:border-l max-sm:-mx-4", options: { direction: }) do
        CarouselContent(class: "max-sm:group-[.is-horizontal]:-ms-2") do
          Book.where(id: books_ids).each do |book|
            CarouselItem(class: "max-sm:basis-xs md:basis-1/2 lg:basis-1/4 max-sm:group-[.is-horizontal]:ps-2") do
              div(class: "pb-0.5") { BookCard(book:) }
            end
          end
        end

        CarouselPrevious(class: "max-sm:hidden sm:group-[.is-horizontal]:left-4")
        CarouselNext(class: "max-sm:hidden sm:group-[.is-horizontal]:right-4")
      end
    end
  end

  def categories
    div(class: "py-16 sm:py-20 flex items-center") do
      div(class: "flex-1 border-t border-border max-sm:-ms-4")
      Text(size: "9", class: "px-4 text-center font-[Cairo] max-sm:text-3xl") { t(".categories") }
      div(class: "flex-1 border-t border-border max-sm:-me-4")
    end

    div(class: "flex justify-center") do
      Card(class: "w-full overflow-hidden") do
        CardContent(class: "p-2 max-h-96 overflow-y-auto") do
          @categories.call.each_with_index do |(id, name, count), index|
            Separator(class: "my-2") unless index.zero?

            Link(href: category_path(id), class: "w-full px-3 py-5 text-foreground hover:bg-accent hover:no-underline") do
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
