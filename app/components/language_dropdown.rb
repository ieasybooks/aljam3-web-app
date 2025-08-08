class Components::LanguageDropdown < Components::Base
  def initialize(placement:) = @placement = placement

  def view_template(&)
    DropdownMenu(options: { placement: @placement }) do
      DropdownMenuTrigger(class: "w-full", &)

      DropdownMenuContent(class: "w-30") do
        I18n.available_locales.each do |locale|
          DropdownMenuItem(
            href: url_for(locale:),
            class: "flex items-center gap-2",
            data: {
              turbo: ("false" unless hotwire_native_app?),
              turbo_action: ("replace" if hotwire_native_app?)
            }
          ) do
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
    when :ur
      Flag::Pk.new(variant: :square, class: "size-5 rounded-full")
    when :en
      Flag::Us.new(variant: :square, class: "size-5 rounded-full")
    end
  end
end
