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
      flash[:notice] = t("devise.omniauth_callbacks.success", kind: provider) if is_navigational_format?
      sign_in_and_redirect user, event: :authentication
    end

    def handle_failed_authentication(provider)
      redirect_to new_user_session_url, alert: t(
        "devise.omniauth_callbacks.failure",
        kind: provider,
        reason: t("devise.omniauth_callbacks.reason", email: auth.info.email)
      )
    end

    def auth = @auth ||= request.env["omniauth.auth"]
  end
end
