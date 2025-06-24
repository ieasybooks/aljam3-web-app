class Views::Devise::Registrations::Edit < Views::Base
  def initialize(minimum_password_length:)
    @minimum_password_length = minimum_password_length
  end

  def page_title = t(".title")

  def view_template
    div(class: "flex flex-col gap-4 justify-center items-center p-4") do
      Card(class: "max-w-md w-full") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "edit_#{resource_name}", class: "edit_#{resource_name}", action: registration_path(resource_name), method: :put, accept_charset: "UTF-8") do
            FormField do
              FormFieldLabel(for: "user_email") { User.human_attribute_name(:email) }

              Input(
                id: "user_email",
                type: :email,
                name: "user[email]",
                value: resource.email,
                autofocus: true,
                required: true,
                autocomplete: "email"
              )

              FormFieldError() { resource.errors.full_messages_for(:email).first }
            end

            if devise_mapping.confirmable? && resource.pending_reconfirmation?
              Text(size: "2", weight: "muted") { t(".currently_waiting_confirmation_for_email", email: resource.unconfirmed_email) }
            end

            FormField do
              FormFieldLabel(for: "user_password") { User.human_attribute_name(:password) }

              Input(
                id: "user_password",
                type: :password,
                name: "user[password]",
                placeholder: t("devise.shared.minimum_password_length", count: @minimum_password_length),
                autocomplete: "new-password",
                minlength: @minimum_password_length
              )

              FormFieldHint() { t(".leave_blank_if_you_don_t_want_to_change_it") }
              FormFieldError() { resource.errors.full_messages_for(:password).first }
            end

            FormField do
              FormFieldLabel(for: "user_password_confirmation") { User.human_attribute_name(:password_confirmation) }

              Input(
                id: "user_password_confirmation",
                type: :password,
                name: "user[password_confirmation]",
                autocomplete: "new-password",
                minlength: @minimum_password_length
              )

              FormFieldError() { resource.errors.full_messages_for(:password_confirmation).first }
            end

            FormField do
              FormFieldLabel(for: "user_current_password") { User.human_attribute_name(:current_password) }

              Input(
                id: "user_current_password",
                type: :password,
                name: "user[current_password]",
                autocomplete: "current-password",
                minlength: @minimum_password_length
              )

              FormFieldHint() { t(".we_need_your_current_password_to_confirm_your_changes") }
              FormFieldError() { resource.errors.full_messages_for(:current_password).first }
            end
          end
        end

        CardFooter do
          Button(type: :submit, form: "edit_#{resource_name}", class: "w-full") { t(".update") }
        end
      end

      Card(class: "max-w-md w-full") do
        CardHeader do
          CardTitle(class: "text-center") { t(".cancel_account") }
        end

        CardContent do
          plain t(".unhappy")
        end

        CardFooter(class: "flex justify-end") do
          Link(href: registration_path(resource_name), variant: :destructive, data: { turbo_method: :delete, turbo_confirm: t(".are_you_sure") }) { t(".cancel_my_account") }
        end
      end
    end
  end
end
