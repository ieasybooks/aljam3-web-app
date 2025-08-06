module Internationalization
  extend ActiveSupport::Concern

  included do
    around_action :switch_locale

    private

    def switch_locale(&)
      locale = locale_from_url || locale_from_cookies || locale_from_headers || I18n.default_locale
      cookies[:locale] = locale

      response.set_header "Content-Language", locale
      I18n.with_locale(locale, &)
    end

    def locale_from_url
      locale = params[:locale]

      locale if I18n.available_locales.map(&:to_s).include?(locale)
    end

    def locale_from_cookies
      locale = cookies[:locale]

      locale if I18n.available_locales.map(&:to_s).include?(locale)
    end

    def locale_from_headers
      header = request.env["HTTP_ACCEPT_LANGUAGE"]
      return if header.nil?

      locales = parse_header header
      return if locales.empty?

      detect_from_available locales
    end

    def parse_header(header)
      header.gsub(/\s+/, "").split(",").map do |language_tag|
        locale, quality = language_tag.split(/;q=/i)
        quality = quality ? quality.to_f : 1.0
        [ locale, quality ]
      end.reject { |(locale, quality)| locale == "*" || quality.zero? }.sort_by { |(_, quality)| quality }.map(&:first)
    end

    def detect_from_available(locales) = locales.reverse.find { |l| I18n.available_locales.any? { |al| match?(al, l) } }
    def match?(str1, str2) = str1.to_s.casecmp(str2.to_s).zero?
    def default_url_options = { locale: I18n.locale }
  end
end
