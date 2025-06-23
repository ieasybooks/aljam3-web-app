class Views::Devise::Passwords::New < Views::Base
  def page_title = t(".forgot_your_password")

  def view_template
    div(class: "flex justify-center items-center p-4") do
      Card(class: "w-md") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "new_#{resource_name}", class: "new_#{resource_name}", action: password_path(resource_name), method: :post, accept_charset: "UTF-8") do
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
          end
        end

        CardFooter do
          Button(type: :submit, form: "new_#{resource_name}", class: "w-full") { t(".send_me_reset_password_instructions") }
        end
      end
    end
  end
end
