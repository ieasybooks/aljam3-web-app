# frozen_string_literal: true

class Components::SetEnglishLanguage < Components::Base
  def view_template(&)
    div(**attrs, &)
  end

  def default_attrs
    {
      class: (I18n.locale == :en ? "" : "hidden"),
      data: { controller: "language-toggle", action: "click->language-toggle#setArabicLanguage" }
    }
  end
end 