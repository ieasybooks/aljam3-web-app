# frozen_string_literal: true

class Components::LanguageToggle < Components::Base
  def view_template(&)
    div(**attrs, &)
  end
end 