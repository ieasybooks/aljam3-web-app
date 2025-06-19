# frozen_string_literal: true

class Components::CloudflareTurnstile < Components::Base
  def initialize(**attrs)
    super(**attrs)
  end

  def view_template
    div(**attrs) do
      cloudflare_turnstile
    end
  end

  private

  def default_attrs = { data: { controller: "cloudflare-turnstile" } }
end
