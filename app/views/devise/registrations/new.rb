class Views::Devise::Registrations::New < Views::Base
  def initialize(minimum_password_length:)
    @minimum_password_length = minimum_password_length
  end

  def page_title = t(".sign_up")

  def view_template
    div(class: "flex justify-center items-center p-4") do
      Card(class: "w-md") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "new_#{resource_name}", class: "new_#{resource_name}", action: registration_path(resource_name), method: :post, accept_charset: "UTF-8") do
            FormField do
              FormFieldLabel(for: "user_email") { User.human_attribute_name(:email) }

              Input(
                id: "user_email",
                type: :email,
                name: "user[email]",
                value: params.dig(:user, :email),
                autofocus: true,
                required: true,
                autocomplete: "email"
              )

              FormFieldError() { resource.errors.full_messages_for(:email).first }
            end

            FormField do
              FormFieldLabel(for: "user_password") { User.human_attribute_name(:password) }

              Input(
                id: "user_password",
                type: :password,
                name: "user[password]",
                placeholder: t("devise.shared.minimum_password_length", count: @minimum_password_length),
                required: true,
                autocomplete: "new-password",
                minlength: @minimum_password_length
              )

              FormFieldError() { resource.errors.full_messages_for(:password).first }
            end

            FormField do
              FormFieldLabel(for: "user_password_confirmation") { User.human_attribute_name(:password_confirmation) }

              Input(
                id: "user_password_confirmation",
                type: :password,
                name: "user[password_confirmation]",
                required: true,
                autocomplete: "new-password",
                minlength: @minimum_password_length
              )

              FormFieldError() { resource.errors.full_messages_for(:password_confirmation).first }
            end
          end
        end

        CardFooter do
          Button(type: :submit, form: "new_#{resource_name}", class: "w-full") { t(".sign_up") }
        end
      end
    end
  end
end
