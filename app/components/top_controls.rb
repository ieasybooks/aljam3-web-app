# frozen_string_literal: true

class Components::TopControls < Components::Base
  def initialize(book:, files:)
    @book = book
    @files = files
  end

  def view_template
    ControlsBar(
      data: {
        top_controls_book_title_value: @book.title,
        top_controls_copy_text_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_download_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_copy_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_hide_tashkeel_text_value: t(".hide_tashkeel"),
        top_controls_show_tashkeel_text_value: t(".show_tashkeel"),
        top_controls_hide_tashkeel_tooltip_value: t(".hide_tashkeel_tooltip"),
        top_controls_show_tashkeel_tooltip_value: t(".show_tashkeel_tooltip")
      }
    ) do |bar|
      txt_indicator

      div(class: "w-full flex justify-between sm:justify-center items-center gap-x-2") do
        right_side_controls(bar)

        Separator(orientation: :vertical, class: "h-6 max-sm:hidden")

        layout_controls(bar)

        Separator(orientation: :vertical, class: "h-6 max-sm:hidden")

        left_side_controls(bar)
      end

      pdf_indicator
    end
  end

  private

  def txt_indicator
    div(class: "w-30 flex justify-start items-center ps-2 max-sm:hidden", data: { top_controls_target: "txtIndicator" }) do
      Text(weight: "bold") { t(".book_txt") }
    end
  end

  def right_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      search_button(bar)
      copy_text_button(bar)
      tashkeel_toggle_button(bar)
      text_size_dropdown(bar)
    end

    right_side_mobile_controls(bar)
  end

  def layout_controls(bar)
    div(class: "flex items-center gap-x-1 sm:gap-x-2") do
      txt_content_only_button(bar)
      txt_and_pdf_content_button(bar)
      pdf_content_only_button(bar)
    end
  end

  def left_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      download_image_button(bar)
      copy_image_button(bar)
      download_files_button(bar)
    end
  end

  def pdf_indicator
    div(class: "w-30 flex justify-end items-center pe-2 max-sm:hidden", data: { top_controls_target: "pdfIndicator" }) do
      Text(weight: "bold") { t(".book_pdf") }
    end
  end

  def search_button(bar)
    search_dialog do
      bar.tooltip(text: t(".search")) do
        bar.button do
          Hero::MagnifyingGlass(class: "size-5.5 ltr:transform ltr:-scale-x-100")
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

  def tashkeel_toggle_button(bar)
    bar.tooltip(text: t(".hide_tashkeel_tooltip")) do
      bar.button(
        data: {
          action: "click->top-controls#toggleTashkeel",
          top_controls_target: "tashkeelToggleButton"
        }
      ) do
        # Eye icon (default state - showing tashkeel)
        Lucide::Eye(
          class: "size-5 transition-all duration-200",
          data: { top_controls_target: "tashkeelToggleIconEye" }
        )
        # EyeOff icon (hidden state - tashkeel hidden)
        Lucide::EyeOff(
          class: "size-5 transition-all duration-200 hidden",
          data: { top_controls_target: "tashkeelToggleIconEyeOff" }
        )
      end
    end
  end

  def text_size_dropdown(bar)
    DropdownMenu(options: { placement: rtl? ? "bottom-start" : "bottom-end" }) do
      DropdownMenuTrigger do
        bar.tooltip(text: t(".text_size")) do
          bar.button do
            Tabler::TextSize(variant: :outline, class: "size-5 rtl:transform rtl:-scale-x-100")
          end
        end
      end

      DropdownMenuContent(class: "w-40") do
        DropdownMenuItem(
          as: :button,
          class: "w-full",
          data_action!: "click->top-controls#textSizeIncrease",
          data_top_controls_target: "textSizeIncreaseButton"
        ) do
          div(class: "flex items-center gap-x-2") do
            Tabler::TextIncrease(variant: :outline, class: "size-5")

            plain t(".text_size_increase")
          end
        end

        DropdownMenuItem(
          as: :button,
          class: "w-full",
          data_action!: "click->top-controls#textSizeDecrease",
          data_top_controls_target: "textSizeDecreaseButton"
        ) do
          div(class: "flex items-center gap-x-2") do
            Tabler::TextDecrease(variant: :outline, class: "size-5")

            plain t(".text_size_decrease")
          end
        end
      end
    end
  end

  def right_side_mobile_controls(bar)
    div(class: "sm:hidden flex items-center gap-x-2") do
      DropdownMenu(options: { placement: rtl? ? "bottom-end" : "bottom-start" }) do
        DropdownMenuTrigger(class: "w-full") do
          bar.button { Lucide::Menu(class: "size-5") }
        end

        DropdownMenuContent(class: "w-40") do
          search_dialog do
            DropdownMenuItem(as: :button, class: "w-full") do
              div(class: "w-full flex items-center gap-x-2") do
                Hero::MagnifyingGlass(class: "size-5 ltr:transform ltr:-scale-x-100")

                plain t(".search")
              end
            end
          end

          DropdownMenuItem(as: :button, class: "w-full", data_action: "click->top-controls#copyText") do
            div(class: "w-full flex items-center gap-x-2") do
              Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")

              plain t(".copy_content")
            end
          end

          DropdownMenuItem(as: :button, class: "w-full", data_action: "click->top-controls#toggleTashkeel") do
            div(class: "w-full flex items-center gap-x-2") do
              # Eye icon for mobile (default state)
              Lucide::Eye(
                class: "size-5 transition-all duration-200",
                data: { top_controls_target: "tashkeelToggleIconEyeMobile" }
              )
              # EyeOff icon for mobile (hidden state)
              Lucide::EyeOff(
                class: "size-5 transition-all duration-200 hidden",
                data: { top_controls_target: "tashkeelToggleIconEyeOffMobile" }
              )

              span(data: { top_controls_target: "tashkeelToggleTextMobile" }) { t(".hide_tashkeel") }
            end
          end

          DropdownMenuItem(as: :button, class: "w-full", data_action: "click->top-controls#textSizeIncrease") do
            div(class: "w-full flex items-center gap-x-2") do
              Tabler::TextIncrease(variant: :outline, class: "size-5")

              plain t(".text_size_increase")
            end
          end

          DropdownMenuItem(as: :button, class: "w-full", data_action: "click->top-controls#textSizeDecrease") do
            div(class: "w-full flex items-center gap-x-2") do
              Tabler::TextDecrease(variant: :outline, class: "size-5")

              plain t(".text_size_decrease")
            end
          end

          DropdownMenuItem(as: :button, class: "w-full", data_action: "click->top-controls#downloadImage") do
            div(class: "w-full flex items-center gap-x-2") do
              Lucide::ImageDown(class: "size-5 ltr:transform ltr:-scale-x-100")

              plain t(".download_image")
            end
          end

          DropdownMenuItem(as: :button, class: "w-full max-sm:hidden", data_action: "click->top-controls#copyImage") do
            div(class: "w-full flex items-center gap-x-2") do
              Lucide::Images(class: "size-5 ltr:transform ltr:-scale-x-100")

              plain t(".copy_image")
            end
          end
        end
      end

      download_files_button(bar)
    end
  end

  def txt_content_only_button(bar)
    bar.tooltip(text: t(".txt_content_only")) do
      bar.button(data: { action: "click->top-controls#txtContentOnly", top_controls_target: "txtContentOnlyButton" }) do
        Tabler::LayoutSidebarRightExpand(variant: :outline, class: "max-sm:hidden sm:block size-6 ltr:transform ltr:-scale-x-100")
        Bootstrap::FiletypeTxt(class: "max-sm:block sm:hidden size-5")
      end
    end
  end

  def txt_and_pdf_content_button(bar)
    bar.tooltip(text: t(".txt_and_pdf_content")) do
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
  end

  def pdf_content_only_button(bar)
    bar.tooltip(text: t(".pdf_content_only")) do
      bar.button(data: { action: "click->top-controls#pdfContentOnly", top_controls_target: "pdfContentOnlyButton" }) do
        Tabler::LayoutSidebarRightCollapse(variant: :outline, class: "max-sm:hidden sm:block size-6 ltr:transform ltr:-scale-x-100")
        Bootstrap::FiletypePdf(class: "max-sm:block sm:hidden size-5")
      end
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

  def search_dialog(&)
    Dialog do
      DialogTrigger(class: "w-full") do
        yield
      end

      DialogContent(size: :xl, class: "p-4") do
        DialogHeader do
          DialogTitle { t(".search") }
        end

        DialogMiddle(class: "py-0") do
          BookSearchForm(book: @book)

          turbo_frame_tag :results_list
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

                  [
                    { url: file.pdf_url, extension: "pdf" },
                    { url: file.txt_url, extension: "txt" },
                    { url: file.docx_url, extension: "docx" }
                  ].each do |file_info|
                    TableCell(class: "text-center") do
                      Button(
                        variant: :outline,
                        size: :sm,
                        icon: true,
                        data: {
                          controller: "download-file",
                          action: "click->download-file#download",
                          download_file_url_value: file_info[:url],
                          download_file_filename_value: "#{file.book.title} - #{file.name}.#{file_info[:extension]}",
                          download_file_loading_status_value: capture { render Lucide::LoaderCircle.new(class: "size-3.5 animate-spin") }
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
