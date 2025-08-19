class Components::BookSearchForm < Components::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    Form(action: book_search_path(@book.id), method: :get, accept_charset: "UTF-8") do
      div(class: "flex items-top gap-x-4") do
        FormField(class: "flex-grow space-y-0") do
          Hero::MagnifyingGlass(class: "size-6 absolute translate-x-[-50%] translate-y-[50%] ltr:translate-x-[50%] ltr:transform ltr:-scale-x-100")

          Input(
            type: :search,
            name: "q",
            value: params[:q],
            class: "h-12 px-4 ps-11 text-base",
            placeholder: t(".search_input_placeholder"),
            required: true,
            minlength: 3,
            maxlength: 255,
            data: {
              value_missing: t("validation_messages.value_missing"),
              too_short: t("validation_messages.too_short", count: 3),
              too_long: t("validation_messages.too_long", count: 255)
            }
          )

          FormFieldError(class: "mt-2") { }
        end

        Button(
          variant: :primary,
          size: :xl,
          type: :submit,
          icon: true,
          class: "flex-shrink-0",
          data: {
            turbo_submits_with: capture { render Lucide::LoaderCircle.new(class: "size-6 animate-spin") }
          }
        ) do
          Hero::PaperAirplane(class: "size-6 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
