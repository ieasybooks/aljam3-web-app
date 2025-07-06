# frozen_string_literal: true

class Components::Logo < Components::Base
  def view_template
    a(href: root_path, class: "me-4 flex items-center font-[lalezar]") do
      Aljam3Logo(class: "h-9 text-primary")
    end
  end
end
