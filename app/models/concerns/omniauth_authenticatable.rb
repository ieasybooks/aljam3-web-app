module OmniauthAuthenticatable
  extend ActiveSupport::Concern

  class_methods do
    def from_omniauth(auth)
      user = find_or_create_by_auth(auth)

      user.update(provider: auth.provider, uid: auth.uid) if user.provider.nil?
      user.confirm unless user.confirmed?

      user
    end

    private

    def find_or_create_by_auth(auth)
      where(email: auth.info.email).first_or_create do |new_user|
        new_user.assign_attributes({
          email: auth.info.email,
          password: Devise.friendly_token[0, 20],
          provider: auth.provider,
          uid: auth.uid
        })

        new_user.skip_confirmation!
      end
    end
  end
end
