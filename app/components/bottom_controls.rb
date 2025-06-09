# frozen_string_literal: true

class Components::BottomControls < Components::Base
  def view_template
    ControlsBar(class: "justify-center") do |bar|
      div(class: "flex items-center gap-x-2") do
        first_page_button(bar)
        previous_page_button(bar)
        next_page_button(bar)
        last_page_button(bar)
      end
    end
  end

  private

  def first_page_button(bar)
    bar.tooltip(text: t(".first_page"), content_data: { bottom_controls_target: "firstPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#firstPage", bottom_controls_target: "firstPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronDoubleLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def previous_page_button(bar)
    bar.tooltip(text: t(".previous_page"), content_data: { bottom_controls_target: "previousPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#previousPage", bottom_controls_target: "previousPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def next_page_button(bar)
    bar.tooltip(text: t(".next_page"), content_data: { bottom_controls_target: "nextPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#nextPage", bottom_controls_target: "nextPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def last_page_button(bar)
    bar.tooltip(text: t(".last_page"), content_data: { bottom_controls_target: "lastPageButtonTooltip" }) do
      bar.button(
        data: { action: "click->bottom-controls#lastPage", bottom_controls_target: "lastPageButton" },
        disabled: "true",
      ) do
        Hero::ChevronDoubleRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end
end
