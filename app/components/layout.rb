# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    doctype

    html dir: direction, lang: I18n.locale do
      Head(@page_info)

      body(
        data: {
          controller: [
            "sync-value",
            ("bridge--menu-button bridge--theme sync-direction" if hotwire_native_app?),
            ("bridge--locale" if ios_native_app?)
          ],
          bridge__menu_button_position_value: (side if hotwire_native_app?),
          sync_direction_rtl_languages_value: (RTL_LANGUAGES.to_json if hotwire_native_app?),
          sync_direction_ltr_languages_value: (LTR_LANGUAGES.to_json if hotwire_native_app?)
        }
      ) do
        Banner() unless @page_info.no_banner
        Navbar() unless @page_info.no_navbar
        Flash(flash:)

        yield
      end
    end
  end
end
