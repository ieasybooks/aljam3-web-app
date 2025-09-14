module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2 = process_oauth_callback("Google")

    private

    def process_oauth_callback(provider)
      user = User.from_omniauth(auth)

      if user.present?
        handle_successful_authentication(user, provider)
      else
        handle_failed_authentication(provider)
      end
    end

    def handle_successful_authentication(user, provider)
      sign_out_all_scopes
      sign_in(user)

      if native_oauth_request?
        token = user.signed_id(purpose: "native_handoff", expires_in: 5.minutes)

        redirect_to handoff_native_session_url(token:)
      else
        flash[:notice] = t("devise.omniauth_callbacks.success", kind: provider) if is_navigational_format?

        redirect_to after_sign_in_path_for(user)
      end
    end

    def handle_failed_authentication(provider)
      redirect_to new_user_session_url, alert: t(
        "devise.omniauth_callbacks.failure",
        kind: provider,
        reason: t("devise.omniauth_callbacks.reason", email: auth.info.email)
      )
    end

    def auth = @auth ||= request.env["omniauth.auth"]

    def native_oauth_request?
      p = request.env["omniauth.params"] || {}
      p["native"] == "1"
    end
  end
end
