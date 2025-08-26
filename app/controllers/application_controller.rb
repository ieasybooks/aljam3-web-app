class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Internationalization

  # Only allow browsers supporting TailwindCSS v4.
  allow_browser versions: { chrome: 111, safari: 16.4, firefox: 128 }, block: :handle_outdated_browser

  before_action :check_rack_mini_profiler

  private

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end

  def handle_outdated_browser = render Views::Errors::UnsupportedBrowser.new
end
