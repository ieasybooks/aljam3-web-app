source "https://rubygems.org"

# Added gems ↓

gem "devise", "~> 4.9", ">= 4.9.4"
gem "devise-i18n", "~> 1.13"
gem "goldiloader", "~> 5.4"
gem "meilisearch-rails", "~> 0.15.0"
gem "memory_profiler", "~> 1.0", ">= 1.0.2" # rack-mini-profiler dependency to profile memory usage.
gem "mission_control-jobs", "~> 1.0", ">= 1.0.2"
gem "oj", "~> 3.16", ">= 3.16.10"
gem "omniauth", "~> 2.1", ">= 2.1.3"
gem "omniauth-google-oauth2", "~> 1.2", ">= 1.2.1"
gem "omniauth-rails_csrf_protection", "~> 1.0", ">= 1.0.2"
gem "pagy", "~> 9.3", ">= 9.3.4"
gem "phlex-icons", "~> 2.22"
gem "phlex-rails", "~> 2.2"
gem "rack-attack", "~> 6.7"
gem "rails_cloudflare_turnstile", "~> 0.4.1"
gem "rails-i18n", "~> 8.0", ">= 8.0.1"
gem "solid_errors", "~> 0.6.1"
gem "stackprof", "~> 0.2.27" # rack-mini-profiler dependency to generate flamegraphs.
gem "strict_ivars", "~> 1.0", ">= 1.0.2", require: false
gem "tailwind_merge", "~> 1.2"

group :development do
  gem "annotaterb", "~> 4.15"
  gem "better_errors", "~> 2.10", ">= 2.10.1"
  gem "binding_of_caller", "~> 1.0", ">= 1.0.1"
  gem "faker", "~> 3.5", ">= 3.5.1", require: false
  gem "hotwire-spark", "~> 0.1.13"
  gem "i18n-tasks", "~> 1.0", ">= 1.0.15"
  gem "rubocop-rake", "~> 0.7.1"
  gem "rubocop-rspec", "~> 3.6"
  gem "rubocop-rspec_rails", "~> 2.31"
  gem "ruby_ui", "~> 1.0", ">= 1.0.1"
end

group :test do
  gem "factory_bot_rails", "~> 6.4", ">= 6.4.4"
  gem "shoulda-matchers", "~> 6.5"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-json", "~> 0.2.3"
end

group :development, :test do
  gem "rspec-rails", "~> 8.0"
end

group :production do
  gem "cloudflare-rails", "~> 6.2"
end

# Template gems ↓

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

# Added gems ↓

gem "rack-mini-profiler", "~> 3.3", ">= 3.3.1" # Needs to be added after `pg` gem for auto-detection.
