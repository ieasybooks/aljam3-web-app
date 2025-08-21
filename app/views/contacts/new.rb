class Views::Contacts::New < Views::Base
  def page_title = t("contact_dialog.contact_us_title")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      Text(class: "mb-4") { t("contact_dialog.contact_us_description") }

      ContactForm(contact: Contact.new)

      Button(
        type: :submit,
        form: :new_contact,
        class: "mt-4 w-full",
        data: {
          turbo_submits_with: capture { render Lucide::LoaderCircle.new(class: "size-5 animate-spin") }
        }
      ) { t("contact_dialog.send") }
    end
  end
end
