require "rails/application_controller"

module Rails
  class PwaController < ApplicationController
    skip_forgery_protection

    def service_worker
      respond_to do |format|
        format.any { render template: "pwa/service-worker", layout: false, formats: [ :js ] }
      end
    end

    def manifest
      respond_to do |format|
        format.any { render template: "pwa/manifest", layout: false, formats: [ :json ] }
      end
    end

    # Serve Apple App Site Association with correct content type
    # Supports requests with and without extension under /.well-known/
    def apple_app_site_association
      # Prefer a template for easier future edits; fallback to static hash if needed
      respond_to do |format|
        format.any do
          # Ensure exactly "application/json" without charset parameter
          response.charset = nil
          render json: apple_association_payload, content_type: "application/json", charset: nil, layout: false
        end
      end
    end

    private

    def apple_association_payload
      {
        webcredentials: {
          apps: [
            "6VU6999229.com.ieasybooks.aljame3"
          ]
        }
      }
    end
  end
end
