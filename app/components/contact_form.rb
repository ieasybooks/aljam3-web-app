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
        FormFieldLabel(for: :contact_name) { Contact.human_attribute_name(:name) }
        Input(
          id: :contact_name,
          class: "text-base",
          name: "contact[name]",
          value: @contact.name,
          required: true,
          minlength: 5,
          maxlength: 255,
          data: {
            value_missing: t("validation_messages.value_missing"),
            too_short: t("validation_messages.too_short", count: 5),
            too_long: t("validation_messages.too_long", count: 255)
          }
        )
        FormFieldError() { @contact.errors.full_messages_for(:name).first }
      end

      FormField do
        FormFieldLabel(for: :contact_email) { Contact.human_attribute_name(:email) }
        Input(
          id: :contact_email,
          type: :email,
          class: "text-base",
          name: "contact[email]",
          value: @contact.email,
          required: true,
          minlength: 5,
          maxlength: 255,
          data: {
            value_missing: t("validation_messages.value_missing"),
            too_short: t("validation_messages.too_short", count: 5),
            too_long: t("validation_messages.too_long", count: 255),
            type_mismatch: t("validation_messages.type_mismatch_email")
          }
        )
        FormFieldError() { @contact.errors.full_messages_for(:email).first }
      end

      FormField do
        FormFieldLabel(for: :contact_topic) { Contact.human_attribute_name(:topic) }
        Input(
          id: :contact_topic,
          class: "text-base",
          name: "contact[topic]",
          value: @contact.topic,
          required: true,
          minlength: 5,
          maxlength: 255,
          data: {
            value_missing: t("validation_messages.value_missing"),
            too_short: t("validation_messages.too_short", count: 5),
            too_long: t("validation_messages.too_long", count: 255)
          }
        )
        FormFieldError() { @contact.errors.full_messages_for(:topic).first }
      end

      FormField do
        FormFieldLabel(for: :contact_message) { Contact.human_attribute_name(:message) }

        Textarea(
          id: :contact_message,
          class: "text-base",
          name: "contact[message]",
          required: true,
          minlength: 15,
          maxlength: 5000,
          data: {
            value_missing: t("validation_messages.value_missing"),
            too_short: t("validation_messages.too_short", count: 15),
            too_long: t("validation_messages.too_long", count: 5000)
          }
        ) do
          @contact.message
        end

        FormFieldError() { @contact.errors.full_messages_for(:message).first }
      end

      CloudflareTurnstile(
        class: "mt-4",
        data: ({ delay: 1000 } if hotwire_native_app?)
      )
    end
  end
end
