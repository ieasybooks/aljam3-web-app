# frozen_string_literal: true

class Components::TextSeparator < Components::Base
  def initialize(text:, **attrs)
    @text = text

    super(**attrs)
  end

  def view_template
    div(**attrs) do
      div(class: "flex-1 border-t border-border")

      Text(class: "px-3") { @text }

      div(class: "flex-1 border-t border-border")
    end
  end

  private

  def default_attrs = { class: "flex justify-center items-center w-full" }
end
