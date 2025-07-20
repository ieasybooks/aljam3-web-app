# frozen_string_literal: true

module RubyUI
  class SetArabicLanguage < Base
    def view_template(&)
      div(**attrs, &)
    end

    def default_attrs
      {
        class: (I18n.locale == :ar ? "" : "hidden"),
        data: { controller: "ruby-ui--language-toggle", action: "click->ruby-ui--language-toggle#setEnglishLanguage" }
      }
    end
  end
end 