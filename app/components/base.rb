# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Components
  include RubyUI
  include PhlexIcons

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::Request
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::SimpleFormat
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::TurboFrameTag
  include Phlex::Rails::Layout

  register_value_helper :params

  def self.translation_path
    @translation_path ||= name&.dup.tap do |n|
      n.gsub!("::", ".")
      n.gsub!(/([a-z])([A-Z])/, '\1_\2')
      n.downcase!
      n.delete_prefix!("views.")
      n.delete_prefix!("components.")
    end
  end

  def html_dir = rtl? ? :rtl : :ltr
  def sheet_side = rtl? ? :right : :left
  def rtl? = I18n.locale == :ar

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
