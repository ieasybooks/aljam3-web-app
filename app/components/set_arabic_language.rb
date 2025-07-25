# frozen_string_literal: true

class Components::SetArabicLanguage < Components::Base
  def view_template(&)
    div(**attrs, &)
  end

  def default_attrs
    {
      class: (I18n.locale == :ar ? "" : "hidden"),
      data: { controller: "language-toggle", action: "click->language-toggle#setEnglishLanguage" }
    }
  end
end 