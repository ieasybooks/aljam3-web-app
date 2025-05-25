# frozen_string_literal: true

class Components::Head < Components::Base
  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    head do
      title { page_title }

      meta name: "viewport", content: "width=device-width,initial-scale=1"
      meta name: "apple-mobile-web-app-capable", content: "yes"
      meta name: "mobile-web-app-capable", content: "yes"

      csrf_meta_tags
      csp_meta_tag

      link rel: "manifest", href: pwa_manifest_path(format: :json)
      link rel: "icon", href: "/icon.png", type: "image/png"
      link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
      link rel: "apple-touch-icon", href: "/icon.png"

      stylesheet_link_tag :app, "data-turbo-track": "reload"
      javascript_include_tag "application", "data-turbo-track": "reload", type: "module"
    end
  end

  private

  def page_title
    if @page_info.title.present?
      "#{t("aljam3")} | #{@page_info.title}"
    else
      t("aljam3")
    end
  end
end
