class Views::Pages::Home < Views::Base
  def initialize(results:)
    @results = results
  end

  def page_title = t(".title")

  def view_template
    div(class: "px-2 sm:px-4 pt-4 sm:container") do
      search_form

      if @results.nil?
        carousel
      else
        if @results.any?
          # TODO: Show the results.
        else
          no_results_found
        end
      end
    end
  end

  private

  def search_form
    Form(action: root_path, method: :get, accept_charset: "UTF-8") do
      div(class: "flex items-top gap-x-4") do
        # TODO: Move the categories extraction logic to a background job.
        SearchRefinementsSheet(
          libraries: Library.all.select(:id, :name),
          categories: Book.all.pluck(:category).uniq.sort
        )

        FormField(class: "flex-grow") do
          Hero::MagnifyingGlass(class: "size-6 absolute translate-x-[-50%] translate-y-[50%]")

          Input(
            type: :search,
            name: "query",
            value: params[:query],
            class: "h-12 px-4 ps-11 text-base",
            placeholder: t(".search_input_placeholder"),
            required: true
          )

          FormFieldError() { }
        end

        Button(
          variant: :primary,
          size: :xl,
          type: :submit,
          icon: true,
          data: {
            turbo_submits_with: capture { render PhlexIcons::Lucide::LoaderCircle.new(class: "size-6 animate-spin") }
          }
        ) do
          Hero::PaperAirplane(class: "size-6 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end

  def carousel
    Heading(level: 2, class: "my-4 mb-5") { t(".discover_books") }

    Carousel(class: "sm:border-r sm:border-l max-sm:mx-10", options: { direction: html_dir }) do
      CarouselContent(class: "max-sm:group-[.is-horizontal]:-ms-2") do
        # TODO: Update the sampling logic later.
        Book.all.sample(10).each do |book|
          CarouselItem(class: "md:basis-1/2 lg:basis-1/4 max-sm:group-[.is-horizontal]:ps-2") do
            div(class: "pb-0.5") { CarouselBookCard(book:) }
          end
        end
      end

      CarouselPrevious(class: "group-[.is-horizontal]:-left-10 sm:group-[.is-horizontal]:left-4")
      CarouselNext(class: "group-[.is-horizontal]:-right-10 sm:group-[.is-horizontal]:right-4")
    end
  end

  def no_results_found
    div(class: "flex flex-col items-center gap-y-5 mt-10 px-4") do
      img(src: "/no_results_found.png", class: "mx-auto w-100")

      Text(size: "7", class: "text-center") { t(".no_results_found") }
    end
  end
end
