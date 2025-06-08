# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(page_info)
    @page_info = page_info
  end

  def view_template
    doctype

    html dir: html_dir, lang: I18n.locale do
      Head(@page_info)

      body(data: { controller: "sync-value" }) do
        Navbar()

        yield
      end
    end
  end
end
