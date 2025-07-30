# frozen_string_literal: true

class Components::LanguageToggle < Components::Base
  def view_template(&)
    div(**attrs) do
      dropdown
    end
  end

  def dropdown
    DropdownMenu(options: { placement: rtl? ? "bottom-start" : "bottom-end" }) do
      DropdownMenuTrigger do
        tooltip(text: t("navbar.language")) do
          button(class: "flex items-center justify-center p-2 rounded-md hover:bg-muted transition-colors") do
            Lucide::Globe(class: "size-5")
          end
        end
      end

      DropdownMenuContent(class: "w-44") do
        language_option(locale: :ar, flag_icon: Flag::Sa, text: "العربية")
        language_option(locale: :en, flag_icon: Flag::Us, text: "English")
      end
    end
  end

  private

  def language_option(locale:, flag_icon:, text:)
    current = I18n.locale == locale

    DropdownMenuItem do
      button(
        type: "button",
        class: "w-full flex items-center gap-x-3 px-2 py-1.5 hover:bg-muted rounded #{current ? 'bg-muted' : ''}",
        data: { 
          controller: "language-toggle", 
          action: "click->language-toggle#switchLanguage",
          language_toggle_locale_param: locale
        }
      ) do
        render flag_icon.new(variant: :rectangle, class: "size-8 flex-shrink-0")
        span(class: "flex-1 text-left") { text }
        if current
          Lucide::Check(class: "size-4 text-muted-foreground flex-shrink-0")
        end
      end
    end
  end

  def tooltip(text:, &)
    data = { 
      controller: "ruby-ui--tooltip",
      ruby_ui__tooltip_options_value: { 
        content: text,
        placement: rtl? ? "bottom-start" : "bottom-end" 
      }.to_json
    }
    
    div(data: data, &)
  end

  def default_attrs
    {
      class: "relative"
    }
  end
end 