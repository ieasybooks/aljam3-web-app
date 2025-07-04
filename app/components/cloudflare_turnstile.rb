# frozen_string_literal: true

class Components::CloudflareTurnstile < Components::Base
  def initialize(**attrs) = super(**attrs)
  def view_template = raw cloudflare_turnstile(**attrs)

  private

  def default_attrs = { data: { controller: "cloudflare-turnstile" } }
end
