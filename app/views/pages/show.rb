class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
    @file = @page.file
    @book = @file.book
    @library = @book.library

    @files = @book.files
  end

  def page_title = t(".title", title: @book.title)
  def description = t(".description", title: @book.title, author: @book.author.name)
  def keywords = [ @book.author.name, @book.category.name ]
  def no_navbar = true

  def view_template
    div(
      class: [
        "flex flex-col sm:container px-4 sm:px-4 py-4 space-y-4",
        ("h-screen" unless ios_native_app?),
        ("h-[calc(100vh-env(safe-area-inset-top)-env(safe-area-inset-bottom))]" if ios_native_app?)
      ],
      data: {
        controller: "pdf-viewer top-controls bottom-controls",
        action: "update-tashkeel-content@window->top-controls#updateTashkeelContent",
        pdf_viewer_book_id_value: @book.id,
        pdf_viewer_file_id_value: @file.id,
        pdf_viewer_current_page_value: @page.number,
        pdf_viewer_skeleton_value: capture { render TxtContentSkeleton() },
        pdf_viewer_loading_error_value: capture { render TxtMessage(variant: :error, text: t(".error_in_loading_page")) },
        pdf_viewer_total_pages_value: @file.pages_count,
        top_controls_book_title_value: @book.title,
        top_controls_copy_text_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_download_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_copy_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_hide_tashkeel_text_value: t(".hide_tashkeel"),
        top_controls_show_tashkeel_text_value: t(".show_tashkeel"),
        bottom_controls_total_pages_value: @file.pages_count
      }
    ) do
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
      end

      div(
        class: "absolute top-0 start-0 h-1 bg-primary transition-all duration-300 ease-out",
        data: { pdf_viewer_target: "progress" }
      )

      header
      content
    end
  end

  private

  def header
    div(class: "relative") do
      share_button unless hotwire_native_app?

      div(class: "flex items-center justify-between") do
        div(class: "flex flex-col items-start gap-y-1") do
          breadcrumb
          title
          author
        end
      end
    end
  end

  def share_button
    Dialog(data: { pdf_viewer_target: "shareDialog" }) do
      DialogTrigger(class: "absolute max-sm:-top-4 max-sm:-end-4 sm:-top-4 sm:end-0") do
        Tooltip(placement: "bottom") do
          TooltipTrigger do
            Button(variant: :outline, icon: true, class: "border-t-0 max-sm:border-e-0 sm:rounded-t-none max-sm:rounded-none max-sm:rounded-es-md") do
              Lucide::Share(class: "size-5")
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
              value: book_file_page_url(@book.id, @file.id, @page.number),
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

  def breadcrumb
    div(class: "flex items-center") do
      MobileMenu(controller_name:, action_name:) unless hotwire_native_app?

      Breadcrumb do
        BreadcrumbList do
          BreadcrumbLink(href: root_path, class: "max-sm:hidden") { Aljam3Logo(class: "h-6 text-primary") }

          BreadcrumbSeparator(class: "max-sm:hidden") { Radix::Slash() }

          # TODO: Add a link to the library page IF implemented.
          BreadcrumbLink(href: "#") { t(".#{@library.name}") }

          BreadcrumbSeparator { Radix::Slash() }

          BreadcrumbLink(href: category_path(@book.category.id)) { @book.category.name }
        end
      end
    end
  end

  def title = Heading(level: "1", class: "max-sm:text-lg line-clamp-3 sm:line-clamp-2") { @book.title }

  def author
    Text(size: "1", weight: "muted", class: "flex gap-x-1") do
      Bootstrap::Feather(class: "size-4")

      a(href: author_path(@book.author), data: { turbo_frame: "_top" }) { @book.author.name }
    end
  end

  def content
    TopControls(book: @book, files: @files)

    div(class: "relative flex-1 flex justify-center gap-2 sm:gap-4 min-h-0", data: { top_controls_target: "contentContainer" }) do
      txt_content
      pdf_content
    end

    BottomControls(book: @book, files: @files, current_file: @file)
  end

  def txt_content
    Card(
      class: "sm:max-w-1/2 flex-1 flex flex-col text-right",
      data: {
        top_controls_target: "txtContent"
      }
    ) do
      CardContent(
        id: "txt-content",
        class: "flex-1 p-4 overflow-y-auto font-[Kitab]",
        data: {
          pdf_viewer_target: "content",
          top_controls_target: "content"
        }) do
        if @page.content.present?
          simple_format @page.content
        else
          TxtMessage(variant: :info, text: t(".empty_page"))
        end
      end
    end
  end

  def pdf_content
    Card(
      class: "sm:max-w-1/2 flex-1 flex flex-col overflow-hidden",
      data: {
        top_controls_target: "pdfContent"
      }
    ) do
      iframe(
        src: pdfjs_path(file: @file.pdf_url, anchor: "page=#{@page.number}"),
        class: "w-full h-full",
        data: {
          pdf_viewer_target: "iframe",
          top_controls_target: "iframe",
          bottom_controls_target: "iframe"
        }
      )
    end
  end
end
