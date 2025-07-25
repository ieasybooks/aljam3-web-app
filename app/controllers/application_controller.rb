class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_locale
  before_action :check_rack_mini_profiler

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end
end
