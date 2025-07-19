class Components::TxtMessage < Components::Base
  VARIANT_CLASSES = {
    info: "text-gray-500 text-2xl",
    error: "text-red-600 text-xl"
  }.freeze

  def initialize(variant:, text:, **attrs)
    @variant = variant
    @text = text

    super(**attrs)
  end

  def view_template
    div(**attrs) do
      plain @text
    end
  end

  private

  def default_attrs
    {
      class: [
        "flex items-center justify-center h-full font-medium text-center",
        VARIANT_CLASSES[@variant]
      ]
    }
  end
end
