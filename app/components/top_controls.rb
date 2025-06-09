# frozen_string_literal: true

class Components::TopControls < Components::Base
  def view_template
    ControlsBar do |bar|
      div(class: "flex items-center gap-x-2") do
        copy_text_button(bar)
        text_size_increase_button(bar)
        text_size_decrease_button(bar)
      end

      div(class: "flex items-center gap-x-2") do
        txt_content_only_button(bar)
        txt_and_pdf_content_button(bar)
        pdf_content_only_button(bar)
      end

      div(class: "flex items-center gap-x-2") do
        bar.dummy_button
        download_image_button(bar)
        copy_image_button(bar)
      end
    end
  end

  private

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
