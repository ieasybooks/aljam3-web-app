# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    doctype

    html dir: html_dir, lang: I18n.locale do
      Head(@page_info)
      Navbar()

      body { yield }
    end
  end
end
