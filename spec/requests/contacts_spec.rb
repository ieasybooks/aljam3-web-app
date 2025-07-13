require "rails_helper"

RSpec.describe "Contacts" do
  describe "POST /contacts" do
    let(:valid_params) do
      {
        contact: {
          name: "Test User",
          email: "test@example.com",
          topic: "Test Topic",
          message: "This is a detailed test message with sufficient length."
        }
      }
    end

    let(:invalid_params) do
      {
        contact: {
          name: "",
          email: "invalid-email",
          topic: "",
          message: "Too short"
        }
      }
    end

    context "when CloudFlare Turnstile response is valid" do
      before do
        stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
          .to_return(status: 200, body: '{"success": true}', headers: { "Content-Type" => "application/json" })
      end

      context "with valid parameters" do
        it "creates a new Contact" do
          expect do
            post contacts_path, params: valid_params, as: :turbo_stream
          end.to change(Contact, :count).by(1)
        end

        it "returns created status" do
          post contacts_path, params: valid_params, as: :turbo_stream

          expect(response).to have_http_status(:created)
        end

        it "replaces the new-contact element" do
          post contacts_path, params: valid_params, as: :turbo_stream

          expect(response.body).to include('turbo-stream action="replace" target="new-contact"')
        end

        it "shows a success message" do
          post contacts_path, params: valid_params, as: :turbo_stream

          expect(response.body).to include(I18n.t("contact_form.contact_received_successfully"))
        end
      end

      context "with invalid parameters" do
        it "does not create a new Contact" do
          expect do
            post contacts_path, params: invalid_params, as: :turbo_stream
          end.not_to change(Contact, :count)
        end

        it "returns unprocessable_entity status" do
          post contacts_path, params: invalid_params, as: :turbo_stream

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when CloudFlare Turnstile response is invalid" do
      before do
        stub_request(:post, "https://challenges.cloudflare.com/turnstile/v0/siteverify")
          .to_return(
            status: 200,
            body: '{"success": false, "error-codes": ["invalid-input-response"]}',
            headers: { "Content-Type" => "application/json" }
          )
      end

      it "does not create a new Contact" do
        expect do
          post contacts_path, params: valid_params, as: :turbo_stream
        end.not_to change(Contact, :count)
      end

      it "returns unprocessable_entity status" do
        post contacts_path, params: valid_params, as: :turbo_stream

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders turbo_stream response with captcha error" do
        post contacts_path, params: valid_params, as: :turbo_stream

        expect(response.body).to include(I18n.t("contact_form.captcha_error"))
      end
    end
  end
end
