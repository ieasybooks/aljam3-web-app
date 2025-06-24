class Views::Devise::Passwords::Edit < Views::Base
  def initialize(minimum_password_length:)
    @minimum_password_length = minimum_password_length
  end

  def page_title = t(".change_your_password")

  def view_template
    div(class: "flex justify-center items-center p-4") do
      Card(class: "w-md") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "edit_#{resource_name}", class: "edit_#{resource_name}", action: password_path(resource_name), method: :put, accept_charset: "UTF-8") do
            input(id: "user_reset_password_token", type: :hidden, name: "user[reset_password_token]", value: params[:reset_password_token])

            FormField do
              FormFieldLabel(for: "user_password") { User.human_attribute_name(:password) }

              Input(
                id: "user_password",
                type: :password,
                name: "user[password]",
                placeholder: t("devise.shared.minimum_password_length", count: @minimum_password_length),
                autofocus: true,
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
          Button(type: :submit, form: "edit_#{resource_name}", class: "w-full") { t(".change_my_password") }
        end
      end
    end
  end
end
