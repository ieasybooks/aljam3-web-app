class Views::Devise::Confirmations::New < Views::Base
  def page_title = t(".resend_confirmation_instructions")

  def view_template
    div(class: "flex justify-center items-center p-4") do
      Card(class: "w-md") do
        CardHeader do
          CardTitle(class: "text-center") { page_title }
        end

        CardContent do
          Form(id: "new_#{resource_name}", class: "new_#{resource_name}", action: confirmation_path(resource_name), method: :post, accept_charset: "UTF-8") do
            FormField do
              FormFieldLabel(for: "user_email") { User.human_attribute_name(:email) }

              Input(
                id: "user_email",
                type: :email,
                name: "user[email]",
                value: (resource.pending_reconfirmation? ? resource.unconfirmed_email : resource.email),
                autofocus: true,
                required: true,
                autocomplete: "email"
              )

              FormFieldError() { resource.errors.full_messages_for(:email).first }
            end
          end
        end

        CardFooter do
          Button(type: :submit, form: "new_#{resource_name}", class: "w-full") { t(".resend_confirmation_instructions") }
        end
      end
    end
  end
end
