class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  before_action :set_locale
  before_action :check_rack_mini_profiler

  def switch_locale
    locale = params[:locale]&.to_sym
    if I18n.available_locales.include?(locale)
      session[:locale] = locale
      I18n.locale = locale
    end
    
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_back_or_to(root_path) }
    end
  end

  private

  def set_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end
end
