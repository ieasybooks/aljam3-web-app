class ApplicationController < ActionController::Base
  include Pagy::Backend
  include Internationalization

  # Only allow browsers supporting TailwindCSS v4.
  allow_browser versions: { chrome: 111, safari: 16.4, firefox: 128 }, block: :handle_outdated_browser

  before_action if: -> { devise_controller? && hotwire_native_app? } do
    request.env["warden"].params["hotwire_native_form"] = true
  end

  before_action :check_rack_mini_profiler
  before_action { Rails.error.set_context(request_url: request.original_url, params: params, session: session.inspect) }

  private

  def after_sign_in_path_for(resource_or_scope)
    return "/reset_app" if hotwire_native_app?

    super
  end

  def check_rack_mini_profiler
    Rack::MiniProfiler.authorize_request if current_user&.admin?
  end

  def handle_outdated_browser = render Views::Errors::UnsupportedBrowser.new
end
