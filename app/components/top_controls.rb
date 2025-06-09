# frozen_string_literal: true

class Components::TopControls < Components::Base
  def view_template
    ControlsBar do |bar|
      right_side_controls(bar)

      div(class: "flex items-center gap-x-2") do
        txt_content_only_button(bar)
        txt_and_pdf_content_button(bar)
        pdf_content_only_button(bar)
      end

      left_side_controls(bar)
    end
  end

  private

  def right_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      copy_text_button(bar)
      text_size_increase_button(bar)
      text_size_decrease_button(bar)
    end

    div(class: "sm:hidden") do
      DropdownMenu(options: { placement: rtl? ? "bottom-end" : "bottom-start" }) do
        DropdownMenuTrigger(class: "w-full") do
          bar.button { Lucide::Menu(class: "size-5") }
        end

        DropdownMenuContent(class: "w-40") do
          DropdownMenuItem(as: :button, data_action: "click->top-controls#copyText") do
            div(class: "flex items-center gap-x-2") do
              Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")

              plain t(".copy_content")
            end
          end

          DropdownMenuItem(as: :button, data_action: "click->top-controls#textSizeIncrease") do
            div(class: "flex items-center gap-x-2") do
              Tabler::TextIncrease(variant: :outline, class: "size-5")

              plain t(".text_size_increase")
            end
          end

          DropdownMenuItem(as: :button, data_action: "click->top-controls#textSizeDecrease") do
            div(class: "flex items-center gap-x-2") do
              Tabler::TextDecrease(variant: :outline, class: "size-5")

              plain t(".text_size_decrease")
            end
          end
        end
      end
    end
  end

  def left_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      bar.dummy_button
      download_image_button(bar)
      copy_image_button(bar)
    end

    div(class: "sm:hidden") do
      DropdownMenu(options: { placement: rtl? ? "bottom-start" : "bottom-end" }) do
        DropdownMenuTrigger(class: "w-full") do
          bar.button { Lucide::Menu(class: "size-5") }
        end

        DropdownMenuContent(class: "w-40") do
          DropdownMenuItem(as: :button, data_action: "click->top-controls#downloadImage") do
            div(class: "flex items-center gap-x-2") do
              Lucide::ImageDown(class: "size-5 ltr:transform ltr:-scale-x-100")

              plain t(".download_image")
            end
          end

          DropdownMenuItem(as: :button, data_action: "click->top-controls#copyImage") do
            div(class: "flex items-center gap-x-2") do
              Lucide::Images(class: "size-5 ltr:transform ltr:-scale-x-100")

              plain t(".copy_image")
            end
          end
        end
      end
    end
  end

  def copy_text_button(bar)
    bar.tooltip(text: t(".copy_content")) do
      bar.button(data: { action: "click->top-controls#copyText", top_controls_target: "copyTextButton" }) do
        Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def text_size_increase_button(bar)
    bar.tooltip(text: t(".text_size_increase")) do
      bar.button(data: { action: "click->top-controls#textSizeIncrease", top_controls_target: "textSizeIncreaseButton" }) do
        Tabler::TextIncrease(variant: :outline, class: "size-5")
      end
    end
  end

  def text_size_decrease_button(bar)
    bar.tooltip(text: t(".text_size_decrease")) do
      bar.button(data: { action: "click->top-controls#textSizeDecrease", top_controls_target: "textSizeDecreaseButton" }) do
        Tabler::TextDecrease(variant: :outline, class: "size-5")
      end
    end
  end

  def txt_content_only_button(bar)
    bar.button(data: { action: "click->top-controls#txtContentOnly", top_controls_target: "txtContentOnlyButton" }) do
      Tabler::LayoutSidebarRightExpand(variant: :outline, class: "max-sm:hidden sm:block size-6")
      Bootstrap::FiletypeTxt(class: "max-sm:block sm:hidden size-5")
    end
  end

  def txt_and_pdf_content_button(bar)
    bar.button(
      class: "max-sm:hidden",
      data: {
        action: "click->top-controls#txtAndPdfContent",
        top_controls_target: "txtAndPdfContentButton"
      }
    ) do
      Tabler::LayoutColumns(variant: :outline, class: "size-6")
    end
  end

  def pdf_content_only_button(bar)
    bar.button(data: { action: "click->top-controls#pdfContentOnly", top_controls_target: "pdfContentOnlyButton" }) do
      Tabler::LayoutSidebarRightCollapse(variant: :outline, class: "max-sm:hidden sm:block size-6")
      Bootstrap::FiletypePdf(class: "max-sm:block sm:hidden size-5")
    end
  end

  def download_image_button(bar)
    bar.tooltip(text: t(".download_image")) do
      bar.button(data: { action: "click->top-controls#downloadImage", top_controls_target: "downloadImageButton" }) do
        Lucide::ImageDown(class: "size-5 ltr:transform ltr:-scale-x-100")
      end
    end
  end

  def copy_image_button(bar)
    bar.tooltip(text: t(".copy_image")) do
      bar.button(data: { action: "click->top-controls#copyImage", top_controls_target: "copyImageButton" }) do
        Lucide::Images(class: "size-5 ltr:transform ltr:-scale-x-100")
      end
    end
  end
end
