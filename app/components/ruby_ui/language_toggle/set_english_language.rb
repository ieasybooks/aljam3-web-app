# frozen_string_literal: true

module RubyUI
  class SetEnglishLanguage < Base
    def view_template(&)
      div(**attrs, &)
    end

    def default_attrs
      {
        class: (I18n.locale == :en ? "" : "hidden"),
        data: { controller: "ruby-ui--language-toggle", action: "click->ruby-ui--language-toggle#setArabicLanguage" }
      }
    end
  end
end 