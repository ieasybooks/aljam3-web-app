class ContactsController < ApplicationController
  before_action :set_contact, only: :create
  before_action :validate_cloudflare_turnstile, only: :create

  rescue_from RailsCloudflareTurnstile::Forbidden, with: :cloudflare_turnstile_handler

  def new = render Views::Contacts::New.new

  def create
    if @contact.save
      response_with(contact: Contact.new, status: :created)
    else
      response_with(contact: @contact, status: :unprocessable_content)
    end
  end

  private

  def set_contact = @contact = Contact.new(contact_params)

  def contact_params = params.expect(contact: %i[name email topic message])

  def cloudflare_turnstile_handler = response_with(contact: @contact, status: :captcha_error)

  def response_with(contact:, status:)
    response_status = status == :captcha_error ? :unprocessable_content : status

    render turbo_stream: turbo_stream.replace(
      "new-contact",
      Components::ContactForm.new(contact:, status:)
    ), status: response_status
  end
end
