# frozen_string_literal: true

module RubyUI
  class LanguageToggle < Base
    def view_template(&)
      div(**attrs, &)
    end
  end
end 