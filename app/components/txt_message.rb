class Components::TxtMessage < Components::Base
  def initialize(variant, text)
    @variant = variant
    @text = text
    @attrs = default_attrs
  end

  def view_template
    div(**attrs) do
      plain @text
    end
  end

  private

  def info_classes = "text-gray-500 text-2xl"
  def error_classes = "text-red-600 text-xl"

  def variant_classes
    {
      info: info_classes,
      error: error_classes
    }[@variant] || ""
  end

  def default_attrs
    {
      class: [
        "flex items-center justify-center h-full font-medium text-center",
        variant_classes
      ]
    }
  end
end
