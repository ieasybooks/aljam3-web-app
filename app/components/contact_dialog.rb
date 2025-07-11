# frozen_string_literal: true

class Components::ContactDialog < Components::Base
  def view_template
    Dialog do
      DialogTrigger do
        yield
      end

      DialogContent(class: "p-4") do
        DialogHeader do
          DialogTitle { t(".contact_us_title") }
          DialogDescription { t(".contact_us_description") }
        end

        DialogMiddle(class: "py-0") do
          ContactForm(contact: Contact.new)
        end

        DialogFooter do
          Button(variant: :outline, data: { action: "click->ruby-ui--dialog#dismiss" }) { t("close") }
          Button(
            type: :submit,
            form: :new_contact,
            data: {
              turbo_submits_with: capture { render Lucide::LoaderCircle.new(class: "size-5 animate-spin") }
            }
          ) { t(".send") }
        end
      end
    end
  end
end
