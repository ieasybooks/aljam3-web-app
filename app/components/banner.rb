# frozen_string_literal: true

class Components::Banner < Components::Base
  URLS = [
    "https://islam200qa.ieasybooks.com",
    "https://baheth.ieasybooks.com",
    "https://app.turath.io",
    "https://shamela.ws",
    "https://tafsir.app",
    "https://read.tafsir.one",
    "https://sunnah.one",
    "https://faidah.app",
    "https://rawy.net",
    "https://alminasa.ai"
  ].freeze

  def initialize = @random_number = rand(URLS.length)

  def view_template
    a(
      class: "w-full flex justify-center items-center gap-x-1 hover:underline text-center px-2 h-10 text-white bg-primary",
      target: "_blank",
      href: URLS[@random_number]
    ) do
      Tabler::Speakerphone(variant: :outline, class: "size-5 rtl:transform rtl:-scale-x-100")

      span(class: "truncate") { t("banner.texts")[@random_number] }
    end
  end
end
