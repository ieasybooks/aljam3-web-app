source "https://rubygems.org"

# Added gems ↓

gem "avo", ">= 3.32.4"
gem "browser", "~> 6.2"
gem "cache_with_locale", "~> 0.0.3"
gem "devise", ">= 5.0.4"
gem "devise-i18n", ">= 1.16.1"
gem "get_process_mem", "~> 1.0"
gem "goldiloader", "~> 6.0"
gem "literal", ">= 1.9"
gem "mcp", "~> 1.6", ">= 1.6.1"
gem "meilisearch-rails", "~> 0.16.0"
gem "memory_profiler", "~> 1.0", ">= 1.0.2" # rack-mini-profiler dependency to profile memory usage.
gem "mission_control-jobs", ">= 1.3.1"
gem "oj", ">= 3.17.7"
gem "omniauth", ">= 2.1.4"
gem "omniauth-google-oauth2", ">= 1.2.3"
gem "omniauth-rails_csrf_protection", ">= 2.0.1"
gem "pagy", "~> 43.7"
gem "pghero", ">= 4.0.1"
gem "pg_query", ">= 6.2.5"
gem "phlex-icons", ">= 2.56"
gem "phlex-rails", "~> 2.3", ">= 2.3.1"
gem "rack-attack", ">= 6.8"
gem "rails_cloudflare_turnstile", ">= 0.5.1"
gem "rails-i18n", ">= 8.1"
gem "rails_performance", ">= 1.6"
gem "rswag-api", "~> 2.16"
gem "rswag-ui", "~> 2.16"
gem "sitemap_generator", ">= 7.1.1"
gem "solid_errors", "~> 0.7.0"
gem "stackprof", ">= 0.2.28" # rack-mini-profiler dependency to generate flamegraphs.
gem "strict_ivars", "~> 1.0", ">= 1.0.2", require: false
gem "sys-cpu", ">= 1.3"
gem "sys-filesystem", ">= 1.6"
gem "tailwind_merge", ">= 1.5.6"

group :development do
  gem "addressable", ">= 2.9"
  gem "annotaterb", ">= 4.25"
  gem "better_errors", "~> 2.10", ">= 2.10.1"
  gem "binding_of_caller", ">= 2.0"
  gem "faker", ">= 3.8"
  gem "hotwire-spark", "~> 0.1.13"
  gem "i18n-tasks", ">= 1.1.2"
  gem "lookbook", ">= 2.3.15"
  gem "net-ssh", ">= 7.3.6"
  gem "rubocop-rake", "~> 0.7.1"
  gem "rubocop-rspec", ">= 3.10.2"
  gem "rubocop-rspec_rails", ">= 2.33"
  gem "ruby_ui", ">= 1.6"
  gem "tqdm", "~> 0.4.1"
end

group :test do
  gem "factory_bot_rails", "~> 6.5", ">= 6.5.1"
  gem "shoulda-matchers", ">= 8.0.1"
  gem "simplecov", ">= 1.3.2", require: false
  gem "simplecov-json", "~> 0.2.3"
  gem "webmock", ">= 3.26.4"
end

group :development, :test do
  gem "active_record_doctor", github: "gregnavis/active_record_doctor"
  gem "rspec-rails", ">= 8.0.4"
  gem "rswag-specs", "~> 2.16"
end

group :production do
  gem "cloudflare-rails", "~> 7.0"
end

# Template gems ↓

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1", ">= 8.1.4"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire"s SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire"s modest JavaScript framework [https://stimulus.hotwired.dev]
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

gem "rack-mini-profiler", ">= 5.0" # Needs to be added after `pg` gem for auto-detection.
