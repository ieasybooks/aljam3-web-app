class ContactFormComponentPreview < Lookbook::Preview
  def default
    render Components::ContactForm.new(contact: Contact.new)
  end

  def created_status
    render Components::ContactForm.new(contact: Contact.new, status: :created)
  end

  def captcha_error_status
    render Components::ContactForm.new(contact: Contact.new, status: :captcha_error)
  end
end
