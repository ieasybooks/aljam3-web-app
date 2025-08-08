# frozen_string_literal: true

class Components::SearchForm < Components::Base
  def initialize(libraries:, categories:)
    @libraries = libraries
    @categories = categories
  end

  def view_template
    Form(action: root_path, method: :get, accept_charset: "UTF-8") do
      div(class: "flex items-top gap-x-4") do
        SearchRefinementsSheet(libraries: @libraries, categories: @categories)

        FormField(class: "flex-grow") do
          Hero::MagnifyingGlass(class: "size-6 absolute translate-x-[-50%] translate-y-[50%] ltr:translate-x-[50%] ltr:transform ltr:-scale-x-100")

          Input(
            type: :search,
            name: "q",
            value: params[:q],
            class: "h-12 px-4 ps-11 text-base",
            placeholder: t(".search_input_placeholder"),
            required: true,
            minlength: 3,
            maxlength: 255
          )

          FormFieldError() { }
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
