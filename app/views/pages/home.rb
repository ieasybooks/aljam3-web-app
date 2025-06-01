class Views::Pages::Home < Views::Base
  def page_title = t(".title")

  def view_template
    div(class: "px-2 sm:px-4 pt-4 sm:container") do
      search_form
    end
  end

  private

  def search_form
    Form(action: root_path, method: :get, accept_charset: "UTF-8") do
      div(class: "flex items-top gap-x-4") do
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
end
