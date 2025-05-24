if ENV["DEPLOY"].blank? && !(Rails.env.local? && Rails.application.credentials.cloudflare.blank?)
  RailsCloudflareTurnstile.configure do |c|
    c.site_key = Rails.application.credentials.cloudflare.turnstile.site_key
    c.secret_key = Rails.application.credentials.cloudflare.turnstile.secret_key
    c.fail_open = true
  end
end
