# frozen_string_literal: true

class Components::ContactForm < Components::Base
  def initialize(contact:, status: nil)
    @contact = contact
    @status = status
  end

  def view_template
    Form(id: :new_contact, action: contacts_path, method: :post, accept_charset: "UTF-8") do
      if @status == :created
        Alert(variant: :success, class: "mb-2") do
          AlertTitle(class: "mb-0") { t(".contact_received_successfully") }
        end
      elsif @status == :captcha_error
        Alert(variant: :destructive, class: "mb-2") do
          AlertTitle(class: "mb-0") { t(".captcha_error") }
        end
      end

      FormField do
        FormFieldLabel { Contact.human_attribute_name(:name) }
        Input(name: "contact[name]", value: @contact.name, required: true, minlength: 5, maxlength: 255)
        FormFieldError() { @contact.errors.full_messages_for(:name).first }
      end

      FormField do
        FormFieldLabel { Contact.human_attribute_name(:email) }
        Input(type: :email, name: "contact[email]", value: @contact.email, required: true, minlength: 5, maxlength: 255)
        FormFieldError() { @contact.errors.full_messages_for(:email).first }
      end

      FormField do
        FormFieldLabel { Contact.human_attribute_name(:topic) }
        Input(name: "contact[topic]", value: @contact.topic, required: true, minlength: 5, maxlength: 255)
        FormFieldError() { @contact.errors.full_messages_for(:topic).first }
      end

      FormField do
        FormFieldLabel { Contact.human_attribute_name(:message) }

        Textarea(name: "contact[message]", required: true, minlength: 15, maxlength: 5000) do
          @contact.message
        end

        FormFieldError() { @contact.errors.full_messages_for(:message).first }
      end

      CloudflareTurnstile(class: "mt-4")
    end
  end
end
