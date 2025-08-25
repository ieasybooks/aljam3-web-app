# frozen_string_literal: true

class Components::TopControls < Components::Base
  def initialize(book:, files:, page: nil, file: nil)
    @book = book
    @files = files
    @page = page
    @file = file
  end

  def view_template
    ControlsBar do |bar|
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
    div(class: "w-35 flex justify-start items-center ps-2 max-sm:hidden", data: { top_controls_target: "txtIndicator" }) do
      Text(weight: "bold") { t(".book_txt") }
    end
  end

  def right_side_controls(bar)
    div(class: "max-sm:hidden flex items-center gap-x-2") do
      search_button(bar)
      copy_text_button(bar)
      text_size_dropdown(bar)
      tashkeel_toggle_button(bar)
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
      share_button(bar)
      bar.dummy_button
    end
  end

  def pdf_indicator
    div(class: "w-35 flex justify-end items-center pe-2 max-sm:hidden", data: { top_controls_target: "pdfIndicator" }) do
      Text(weight: "bold") { t(".book_pdf") }
    end
  end

  def search_button(bar)
    search_dialog do
      bar.tooltip(text: t(".search_in_book")) do
        bar.button do
          Hero::MagnifyingGlass(class: "size-5.5 ltr:transform ltr:-scale-x-100")
        end
      end
    end
  end

  def copy_text_button(bar)
    bar.tooltip(text: t(".copy_page_content")) do
      bar.button(data: { action: "click->top-controls#copyText", top_controls_target: "copyTextButton" }) do
        Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")
      end
    end
  end

  def tashkeel_toggle_button(bar)
    bar.tooltip(text: t(".hide_tashkeel"), content_data: { top_controls_target: "tashkeelToggleTooltip" }) do
      bar.button(
        data: {
          action: "click->top-controls#toggleTashkeel",
          top_controls_target: "tashkeelToggleButton"
        }
      ) do
        CustomIcons::FilledShaddah(
          class: "size-5 transition-all duration-200",
          data: { top_controls_target: "showTashkeelToggleIcon" }
        )

        CustomIcons::DottedShaddah(
          class: "size-5 transition-all duration-200 hidden",
          data: { top_controls_target: "hideTashkeelToggleIcon" }
        )
      end
    end
  end

  def text_size_dropdown(bar)
    DropdownMenu(options: { placement: "bottom-start" }, class: "z-50") do
      DropdownMenuTrigger do
        bar.tooltip(text: t(".text_size")) do
          bar.button do
            Tabler::TextSize(variant: :outline, class: "size-5 rtl:transform rtl:-scale-x-100")
          end
        end
      end

      DropdownMenuContent(class: "w-40 ltr:w-50") do
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
    div(class: "sm:hidden flex items-center gap-x-2 z-50") do
      DropdownMenu(options: { placement: "bottom-end" }) do
        DropdownMenuTrigger(class: "w-full") do
          bar.button { Lucide::Menu(class: "size-5") }
        end

        DropdownMenuContent(class: "w-50") do
          search_dialog do
            DropdownMenuItem(as: :button, class: "w-full") do
              div(class: "w-full flex items-center gap-x-2") do
                Hero::MagnifyingGlass(class: "size-5 ltr:transform ltr:-scale-x-100")

                plain t(".search_in_book")
              end
            end
          end

          DropdownMenuItem(
            as: :button,
            class: "w-full",
            data_action: "click->top-controls#copyText"
          ) do
            div(class: "w-full flex items-center gap-x-2") do
              Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")

              plain t(".copy_page_content")
            end
          end

          DropdownMenuItem(
            as: :button,
            class: "w-full",
            data_action: "click->top-controls#textSizeIncrease",
            data: { top_controls_target: "txtOnlyOption" }
          ) do
            div(class: "w-full flex items-center gap-x-2") do
              Tabler::TextIncrease(variant: :outline, class: "size-5")

              plain t(".text_size_increase")
            end
          end

          DropdownMenuItem(
            as: :button,
            class: "w-full",
            data_action: "click->top-controls#textSizeDecrease",
            data: { top_controls_target: "txtOnlyOption" }
          ) do
            div(class: "w-full flex items-center gap-x-2") do
              Tabler::TextDecrease(variant: :outline, class: "size-5")

              plain t(".text_size_decrease")
            end
          end

          DropdownMenuItem(
            as: :button,
            class: "w-full",
            data_action: "click->top-controls#toggleTashkeel",
            data: { top_controls_target: "txtOnlyOption" }
          ) do
            div(class: "w-full flex items-center gap-x-2") do
              CustomIcons::FilledShaddah(
                class: "size-5 transition-all duration-200",
                data: { top_controls_target: "mobileShowTashkeelToggleIcon" }
              )

              CustomIcons::DottedShaddah(
                class: "size-5 transition-all duration-200 hidden",
                data: { top_controls_target: "mobileHideTashkeelToggleIcon" }
              )

              span(data: { top_controls_target: "mobileTashkeelToggleButton" }) { t(".hide_tashkeel") }
            end
          end
        end
      end

      download_files_button(bar)
      share_button(bar)
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

  def share_button(bar)
    if hotwire_native_app?
      div(
        class: "hidden",
        data: {
          controller: "bridge--share",
          bridge__share_url_value: book_file_page_url(locale: I18n.locale, book_id: @book.id, file_id: @file.id, page_number: @page.number),
          bridge__share_text_value: android_native_app? ? t(".share_text", title: @book.title, author: @book.author.name) : "\n\n#{t(".share_text", title: @book.title, author: @book.author.name)}",
          pdf_viewer_target: "bridgeShare"
        }
      )
    else
      Dialog(data: { pdf_viewer_target: "shareDialog" }) do
        DialogTrigger(class: "") do
          Tooltip(placement: "bottom") do
            TooltipTrigger do
              Button(variant: :outline, icon: true, class: "") do
                Lucide::Share2(class: "size-5")
              end
            end
            TooltipContent(class: "delay-100 max-sm:hidden") do
              Text { t(".share_page") }
            end
          end
        end
        DialogContent(
          class: [
            "p-4",
            ("max-sm:border-x-0 max-sm:light:border-t max-sm:dark:border-y" unless hotwire_native_app?),
            ("border-x-0 light:border-t dark:border-y" if hotwire_native_app?)
          ]
        ) do
          DialogHeader do
            DialogTitle { t(".share_page_dialog_title") }
          end
          DialogMiddle(class: "py-0") do
            div(
              class: "flex items-center",
              data: {
                controller: "clipboard",
                clipboard_success_content_value: capture { render Lucide::Check(class: "size-5") }
              }
            ) do
              Button(
                variant: :outline,
                size: :md,
                icon: true,
                class: "rounded-e-none border-e-0",
                data: {
                  action: "click->clipboard#copy",
                  clipboard_target: "button"
                }
              ) do
                Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")
              end
              Input(
                type: :text,
                value: book_file_page_url(locale: I18n.locale, book_id: @book.id, file_id: @file.id, page_number: @page.number),
                class: "ltr:rounded-s-none rtl:rounded-s-none text-end",
                data: { clipboard_target: "source" },
                readonly: true
              )
            end
          end
          DialogFooter do
            Button(variant: :outline, data: { action: "click->ruby-ui--dialog#dismiss" }) { t("close") }
          end
        end
      end
    end
  end

  def search_dialog(&)
    Dialog do
      DialogTrigger(class: "w-full") do
        yield
      end

      DialogContent(
        size: :xl,
        class: [
          "p-4",
          ("max-h-[min(90vh,600px)]" if ios_native_app?),
          ("max-sm:border-x-0 max-sm:light:border-t max-sm:dark:border-y" unless hotwire_native_app?),
          ("border-x-0 light:border-t dark:border-y" if hotwire_native_app?)
        ]
      ) do
        DialogHeader do
          DialogTitle { t(".search_in_book") }
        end

        DialogMiddle(class: "py-0") do
          BookSearchForm(book: @book)

          turbo_frame_tag :results_count
          turbo_frame_tag :results_list_1
        end
      end
    end
  end

  def download_files_dialog(&)
    Dialog do
      DialogTrigger do
        yield
      end

      DialogContent(
        class: [
          "p-4",
          ("max-sm:border-x-0 max-sm:light:border-t max-sm:dark:border-y" unless hotwire_native_app?),
          ("border-x-0 light:border-t dark:border-y" if hotwire_native_app?)
        ]
      ) do
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
                          controller: [
                            ("file-download" unless hotwire_native_app?),
                            ("bridge--file-download" if hotwire_native_app?)
                          ],
                          action: [
                            ("click->file-download#download" unless hotwire_native_app?),
                            ("click->bridge--file-download#download" if hotwire_native_app?)
                          ],
                          file_download_url_value: (file_info[:url] unless hotwire_native_app?),
                          file_download_filename_value: ("#{file.book.title} - #{file.name}.#{file_info[:extension]}" unless hotwire_native_app?),
                          file_download_loading_status_value: (capture { render Lucide::LoaderCircle.new(class: "size-3.5 animate-spin") } unless hotwire_native_app?),
                          bridge__file_download_url_value: (file_info[:url] if hotwire_native_app?),
                          bridge__file_download_filename_value: ("#{file.book.title} - #{file.name}.#{file_info[:extension]}" if hotwire_native_app?),
                          bridge__file_download_loading_status_value: (capture { render Lucide::LoaderCircle.new(class: "size-3.5 animate-spin") } if hotwire_native_app?)
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
