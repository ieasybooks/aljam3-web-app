# frozen_string_literal: true

class Components::TopControls < Components::Base
  def initialize(files:)
    @files = files
  end

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

    div(class: "sm:hidden flex items-center gap-x-2") do
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

      download_files_button(bar)
    end
  end

  def left_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      download_image_button(bar)
      copy_image_button(bar)
      download_files_button(bar)
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
      Tabler::LayoutSidebarRightExpand(variant: :outline, class: "max-sm:hidden sm:block size-6 ltr:transform ltr:-scale-x-100")
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
      Tabler::LayoutSidebarRightCollapse(variant: :outline, class: "max-sm:hidden sm:block size-6 ltr:transform ltr:-scale-x-100")
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

  def download_files_button(bar)
    download_files_dialog do
      bar.tooltip(text: t(".download_files")) do
        bar.button do
          Lucide::Download(class: "size-5")
        end
      end
    end
  end

  def download_files_dialog(&)
    Dialog do
      DialogTrigger do
        yield
      end

      DialogContent(class: "p-4") do
        DialogHeader do
          DialogTitle { t(".download_files") }
        end

        DialogMiddle(class: "py-0 max-h-96 overflow-y-auto") do
          Table do
            TableHeader do
              TableRow do
                TableHead { "#" }
                TableHead { t(".file_name") }
                TableHead(class: "text-center") { "PDF" }
                TableHead(class: "text-center") { "TXT" }
                TableHead(class: "text-center") { "DOCX" }
              end
            end

            TableBody do
              @files.each_with_index do |file, index|
                TableRow do
                  TableCell { index + 1 }
                  TableCell { file.name }

                  [ file.pdf_url, file.txt_url, file.docx_url ].each do |url|
                    TableCell(class: "text-center") do
                      Button(
                        variant: :outline,
                        size: :sm,
                        icon: true,
                        data: {
                          controller: "download-file",
                          action: "click->download-file#download",
                          download_file_url_value: url
                        }
                      ) do
                        Lucide::Download(variant: :solid, class: "size-3.5")
                      end
                    end
                  end
                end
              end
            end
          end
        end

        DialogFooter do
          Button(variant: :outline, data: { action: "click->ruby-ui--dialog#dismiss" }) { t("close") }
        end
      end
    end
  end
end
