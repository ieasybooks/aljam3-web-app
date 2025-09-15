class SiteController < ApplicationController
  def reset_app
    # Hotwire Native needs an empty page to route authentication and reset the app.
    # We can't head: 200 because we also need the Turbo JavaScript in <head>.

    render Views::Site::ResetApp.new
  end
end
