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

      script do
        raw(safe(
        <<-JS
          if (localStorage.theme === "dark" || (!("theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
            document.documentElement.classList.add("dark");
            document.documentElement.classList.remove("light");
          } else {
            document.documentElement.classList.add("light");
            document.documentElement.classList.remove("dark");
          }
        JS
        ))
      end

      link rel: "manifest", href: pwa_manifest_path(format: :json)
      link rel: "icon", href: "/icon.png", type: "image/png"
      link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
      link rel: "apple-touch-icon", href: "/icon.png"

      link rel: "preconnect", href: "https://fonts.googleapis.com"
      link rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true

      stylesheet_link_tag "application", "data-turbo-track": "reload"
      javascript_include_tag "application", "data-turbo-track": "reload", type: "module"

      link rel: "stylesheet", href: "https://fonts.googleapis.com/css2?family=Lalezar&display=swap&text=#{t("aljam3")}"

      raw cloudflare_turnstile_script_tag
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
