require "test_helper"

class ContactsTest < ApplicationTest
  setup do
    @valid_params = {
      contact: {
        name: "Test User",
        email: "test@example.com",
        topic: "Test Topic",
        message: "This is a detailed test message with sufficient length."
      }
    }
    @invalid_params = {
      contact: {
        name: "",
        email: "invalid-email",
        topic: "",
        message: "Too short"
      }
    }
  end

  test "renders the new contact form" do
    get new_contact_path

    assert_response :success
  end

  test "creates a contact and renders the success stream" do
    stub_turnstile(success: true)

    assert_difference("Contact.count", 1) do
      post contacts_path, params: @valid_params, as: :turbo_stream
    end

    assert_response :created
    assert_includes response.body, 'turbo-stream action="replace" target="new-contact"'
    assert_includes response.body, I18n.t("contact_form.contact_received_successfully")
  end

  test "rejects invalid contact parameters" do
    stub_turnstile(success: true)

    assert_no_difference("Contact.count") do
      post contacts_path, params: @invalid_params, as: :turbo_stream
    end

    assert_response :unprocessable_content
  end

  test "rejects a failed Turnstile response" do
    stub_turnstile(success: false)

    assert_no_difference("Contact.count") do
      post contacts_path, params: @valid_params, as: :turbo_stream
    end

    assert_response :unprocessable_content
    assert_includes response.body, I18n.t("contact_form.captcha_error").gsub("'", "&#39;")
  end

  private

  def stub_turnstile(success:)
    body = success ? { success: true } : { success: false, "error-codes": [ "invalid-input-response" ] }
    stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
      .to_return(status: 200, body: body.to_json, headers: { "Content-Type" => "application/json" })
  end
end
