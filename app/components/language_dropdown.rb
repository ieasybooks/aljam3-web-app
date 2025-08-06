class Components::LanguageDropdown < Components::Base
  def view_template
    DropdownMenu(options: { placement: "bottom-end" }) do
      DropdownMenuTrigger(class: "w-full") do
        Button(variant: :ghost, icon: true) do
          render [
            Bootstrap::GlobeAmericas,
            Bootstrap::GlobeAsiaAustralia,
            Bootstrap::GlobeCentralSouthAsia,
            Bootstrap::GlobeEuropeAfrica
          ].sample.new(class: "size-5")
        end
      end

      DropdownMenuContent(class: "w-30") do
        I18n.available_locales.each do |locale|
          DropdownMenuItem(href: url_for(locale:), class: "flex items-center gap-2", data: { turbo: "false" }) do
            render locale_flag(locale)

            span { t(".#{locale}") }
          end
        end
      end
    end
  end

  private

  def locale_flag(locale)
    case locale
    when :ar
      Flag::Sa.new(variant: :square, class: "size-5 rounded-full")
    when :en
      Flag::Us.new(variant: :square, class: "size-5 rounded-full")
    end
  end
end
