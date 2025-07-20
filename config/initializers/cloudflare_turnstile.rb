if ENV["DEPLOY"].blank? && !(Rails.env.local? && Rails.application.credentials.cloudflare.blank?)
  RailsCloudflareTurnstile.configure do |c|
    c.site_key = Rails.application.credentials.cloudflare.turnstile.site_key
    c.secret_key = Rails.application.credentials.cloudflare.turnstile.secret_key
    c.fail_open = true
  end

  RailsCloudflareTurnstile.configuration.size = :flexible
elsif Rails.env.test?
  # Configure for test environment with mock keys
  RailsCloudflareTurnstile.configure do |c|
    c.site_key = "test_site_key"
    c.secret_key = "test_secret_key"
    c.fail_open = false # Fail closed in tests to properly test validation
  end
end
