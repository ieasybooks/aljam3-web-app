# frozen_string_literal: true

class Components::SearchForm < Components::Base
  def view_template
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
            turbo_submits_with: capture { render Lucide::LoaderCircle.new(class: "size-6 animate-spin") }
          }
        ) do
          Hero::PaperAirplane(class: "size-6 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
