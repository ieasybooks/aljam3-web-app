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
  end
end
