class Components::InlineSearchForm < Components::Base
  def initialize(action:)
    @action = action
  end

  def view_template
    Form(
      action: @action,
      method: :get,
      accept_charset: "UTF-8",
      class: "sm:w-1/3",
      data: {
        turbo_action: "replace",
        turbo_permanent: "",
        controller: "search-auto-submit"
      }
    ) do
      FormField(class: "space-y-0") do
        Hero::MagnifyingGlass(class: "size-6 absolute translate-x-[-50%] translate-y-[50%] ltr:translate-x-[50%] ltr:transform ltr:-scale-x-100")

        Input(
          type: :search,
          name: "q",
          value: params[:q],
          class: "h-12 px-4 ps-11 text-base",
          placeholder: t(".search_input_placeholder"),
          minlength: 3,
          maxlength: 255,
          data: {
            action: "input->search-auto-submit#submit",
            search_auto_submit_target: "input"
          }
        )

        FormFieldError(class: "mt-2") { }
      end
    end
  end
end
