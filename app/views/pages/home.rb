class Views::Pages::Home < Views::Base
  def initialize(results:)
    @results = results
  end

  def page_title = t(".title")

  def view_template
    div(class: "px-2 sm:px-4 pt-4 sm:container") do
      search_form

      if @results.present?
        # TODO: Show the results.
      else
        carousel
      end
    end
  end

  private

  def search_form
    Form(action: root_path, method: :get, accept_charset: "UTF-8") do
      div(class: "flex items-top gap-x-4") do
        refinements_sheet

        Input(
          type: :hidden,
          name: "refinements[search_scope]",
          value: "title-and-content",
          data: {
            sync_value_target: "target",
            sync_id: "refinements[search_scope]"
          }
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

  def refinements_sheet
    Sheet do
      SheetTrigger do
        Button(variant: :secondary, size: :xl, icon: true) do
          Hero::Cog8Tooth(variant: :outline, class: "size-6")
        end
      end

      SheetContent(class: "sm:w-sm") do
        SheetHeader do
          SheetTitle { t(".refinements_sheet_title") }
        end

        SheetMiddle do
          FormField do
            FormFieldLabel { t(".search_scope") }

            Select do
              SelectInput(
                value: "title-and-content",
                id: "select-a-scope",
                data: {
                  sync_value_target: "source",
                  sync_id: "refinements[search_scope]",
                  sync_event: "change"
                }
              )

              SelectTrigger(class: "mt-1") do
                SelectValue(placeholder: t(".search_scope_placeholder"), id: "select-a-scope") { t(".search_scope_title_and_content") }
              end

              SelectContent(outlet_id: "select-a-scope") do
                SelectGroup do
                  SelectItem(value: "title-and-content", aria_selected!: "true") { t(".search_scope_title_and_content") }
                  SelectItem(value: "title") { t(".search_scope_title") }
                  SelectItem(value: "content") { t(".search_scope_content") }
                end
              end
            end
          end
        end

        SheetFooter do
          Button(variant: :outline, data: { action: "click->ruby-ui--sheet-content#close" }) { t("close") }
        end
      end
    end
  end
end
