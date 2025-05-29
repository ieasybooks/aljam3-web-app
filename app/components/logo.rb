# frozen_string_literal: true

class Components::Logo < Components::Base
  def view_template
    a(href: root_path, class: "me-4 flex items-center font-[lalezar]") do
      Heading(level: 1) { t("aljam3") }
    end
  end
end
