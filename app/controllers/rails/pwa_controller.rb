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

    def android_assetlinks
      respond_to do |format|
        format.any do
          render json: android_assetlinks_payload, content_type: "application/json", layout: false
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

    def android_assetlinks_payload
      [
        {
          relation: [ "delegate_permission/common.handle_all_urls" ],
          target: {
            namespace: "android_app",
            package_name: "com.ieasybooks.aljam3",
            sha256_cert_fingerprints: [ "9D:E6:FD:8C:3C:3D:93:57:A5:F4:32:DA:EF:B2:49:2C:E8:46:64:45:BB:B3:77:3F:8A:BA:98:0B:8E:11:7B:4A" ]
          }
        }
      ]
    end
  end
end
