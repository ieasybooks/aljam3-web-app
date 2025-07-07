# frozen_string_literal: true

class Components::Logo < Components::Base
  def initialize(**attrs)
    super(**attrs)
  end

  def view_template
    a(href: root_path, **attrs) do
      Aljam3Logo(class: "h-9 text-primary")
    end
  end

  private

  def default_attrs
    {
      class: "me-4 flex items-center"
    }
  end
end
