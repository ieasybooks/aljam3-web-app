# frozen_string_literal: true

class Components::ControlsBar < Components::Base
  def initialize(**attrs)
    super(**attrs)
  end

  def view_template
    Card do
      CardContent(**attrs) do
        yield
      end
    end
  end

  def tooltip(text:, content_data: {}, &)
    Tooltip do
      TooltipTrigger do
        yield
      end

      TooltipContent(class: "delay-100 max-sm:hidden", data: content_data) do
        Text { text }
      end
    end
  end

  def button(**attrs, &)
    attrs[:variant] ||= :outline
    attrs[:size] ||= :md
    attrs[:icon] ||= true

    Button(**attrs) do
      yield
    end
  end

  def dummy_button = Button(variant: :link, size: :md, icon: true, class: "max-sm:hidden pointer-events-none")

  private

  def default_attrs = { class: "flex items-center justify-between p-2 gap-x-2" }
end
