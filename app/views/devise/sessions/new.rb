class Views::Devise::Sessions::New < Views::Base
  def page_title = t(".sign_in")

  def view_template
    div(class: "flex justify-center items-center p-4") do
      Card(class: "w-md") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "new_#{resource_name}", class: "new_#{resource_name}", action: session_path(resource_name), method: :post, accept_charset: "UTF-8") do
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

              FormFieldError() { }
            end

            FormField do
              FormFieldLabel(for: "user_password") { User.human_attribute_name(:password) }

              Input(
                id: "user_password",
                type: :password,
                name: "user[password]",
                required: true,
                autocomplete: "current-password"
              )

              FormFieldError() { }
            end

            div(class: "flex items-center justify-between mt-3") do
              div(class: "flex items-center space-x-2") do
                Checkbox(id: "user_remember_me", name: "user[remember_me]", checked: params.dig(:user, :remember_me) == "on")

                label(
                  for: "user_remember_me",
                  class: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                ) { User.human_attribute_name(:remember_me) }
              end

              a(href: new_password_path(resource_name), class: "hover:underline") do
                Text(size: "2", weight: "muted") { t(".forgot_your_password") }
              end
            end
          end
        end

        CardFooter do
          Button(type: :submit, form: "new_#{resource_name}", class: "w-full mb-2") { t(".sign_in") }

          Text(size: "2", weight: "muted") do
            plain t(".dont_have_an_account_yet")
            whitespace
            a(href: new_registration_path(resource_name), class: "hover:underline") do
              t(".sign_up_now")
            end
          end
        end
      end
    end
  end
end
