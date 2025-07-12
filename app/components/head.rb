# frozen_string_literal: true

class Components::Head < Components::Base
  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    head do
      title { page_title }

      meta name: "description", content: @page_info.description if @page_info.description.present?
      meta name: "keywords", content: @page_info.keywords.join(", ") if @page_info.keywords.present?

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

      link rel: "manifest", href: pwa_manifest_path(format: :json, v: 2)
      link rel: "icon", href: "/icon.png?v=5", type: "image/png"
      link rel: "apple-touch-icon", href: "/icon.png?v=5"

      stylesheet_link_tag "application", "data-turbo-track": "reload"
      javascript_include_tag "application", "data-turbo-track": "reload", type: "module"

      link rel: "preconnect", href: "https://www.googletagmanager.com"

      script async: true,
               src: "https://www.googletagmanager.com/gtag/js?id=G-VBEGPJJEHW",
               data_turbo_track: "reload"

      script do
        raw(safe(
          <<~JS
            (function(c,l,a,r,i,t,y){
                c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
            })(window, document, "clarity", "script", "sdm48dgk9j");
          JS
        ))
      end

      # raw cloudflare_turnstile_script_tag
      # ^ Renders the below script tag with `data_turbo_temporary: true`, which causes full page reloads.
      script src: "https://challenges.cloudflare.com/turnstile/v0/api.js",
             async: true,
             defer: true,
             data_turbo_track: "reload"
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
