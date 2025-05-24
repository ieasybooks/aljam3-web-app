class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_rack_mini_profiler

  private

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end
end
