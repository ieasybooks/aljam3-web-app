# frozen_string_literal: true

class Components::Base < RubyUI::Base
  def cache_store = Rails.cache

  include Components
  include RubyUI
  include PhlexIcons

  include ::Devise::Controllers::UrlHelpers
  include ::Devise::OmniAuth::UrlHelpers

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Flash
  include Phlex::Rails::Helpers::Request
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::NumberWithDelimiter
  include Phlex::Rails::Helpers::SimpleFormat
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Layout

  register_output_helper :cloudflare_turnstile_script_tag

  register_value_helper :action_name
  register_value_helper :browser
  register_value_helper :cloudflare_turnstile
  register_value_helper :controller_name
  register_value_helper :devise_mapping
  register_value_helper :params
  register_value_helper :resource
  register_value_helper :resource_class
  register_value_helper :resource_name
  register_value_helper :user_signed_in?

  def self.translation_path
    @translation_path ||= name&.dup.tap do |n|
      n.gsub!("::", ".")
      n.gsub!(/([a-z])([A-Z])/, '\1_\2')
      n.downcase!
      n.delete_prefix!("views.")
      n.delete_prefix!("components.")
    end
  end

  def direction = rtl? ? :rtl : :ltr
  def side = rtl? ? :right : :left
  def rtl? = I18n.locale == :ar || I18n.locale == :ur

  def process_meilisearch_highlights(content) = merge_consecutive_marks(remove_definite_articles_marks(content))
  def remove_definite_articles_marks(content) = content&.gsub(/<mark>(ال|أل|إل|آل)<\/mark>(?!<mark>)/, '\1')
  def merge_consecutive_marks(content) = content&.gsub(/<\/mark>(\s*)<mark>/) { Regexp.last_match(1).empty? ? "" : "&nbsp;" }

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
