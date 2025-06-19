class ContactsController < ApplicationController
  def create
    contact = Contact.new(contact_params)

    if contact.save
      response_with(contact: Contact.new, status: :created)
    else
      response_with(contact:, status: :unprocessable_entity)
    end
  end

  private

  def contact_params = params.expect(contact: %i[name email topic message])

  def response_with(contact:, status:)
    render turbo_stream: turbo_stream.replace(
      "new-contact",
      Components::ContactForm.new(contact:, created: status == :created)
    ), status:
  end
end
