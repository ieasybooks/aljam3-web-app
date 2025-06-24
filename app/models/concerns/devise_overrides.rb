module DeviseOverrides
  extend ActiveSupport::Concern

  included do
    def send_devise_notification(notification, *)
      devise_mailer.send(notification, self, *).deliver_later
    end

    def active_for_authentication?
      super && !access_suspended?
    end

    def access_suspended?
      !!suspended_at
    end

    def inactive_message
      if access_locked?
        :locked_html
      elsif !confirmed?
        :unconfirmed_html
      else
        super
      end
    end

    def unauthenticated_message
      if !Devise.paranoid && (access_locked? || (lock_strategy_enabled?(:failed_attempts) && attempts_exceeded?))
        :locked_html
      else
        super
      end
    end
  end
end
