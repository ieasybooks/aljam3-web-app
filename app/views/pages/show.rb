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
      class: "flex flex-col h-screen sm:container px-4 sm:px-4 py-4 space-y-4",
      data: {
        controller: "pdf-viewer top-controls bottom-controls",
        pdf_viewer_book_id_value: @book.id,
        pdf_viewer_file_id_value: @file.id,
        pdf_viewer_current_page_value: @page.number,
        pdf_viewer_skeleton_value: capture { render TxtContentSkeleton() },
        pdf_viewer_total_pages_value: @file.pages_count,
        top_controls_book_title_value: @book.title,
        top_controls_copy_text_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_download_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_copy_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        bottom_controls_total_pages_value: @file.pages_count
      }
    ) do
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
      share_button

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
    Dialog do
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

      DialogContent(class: "p-4") do
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
      MobileMenu()

      Breadcrumb do
        BreadcrumbList do
          BreadcrumbLink(href: root_path, class: "max-sm:hidden font-[lalezar]") { Aljam3Logo(class: "h-6 text-primary") }

          BreadcrumbSeparator(class: "max-sm:hidden") { Radix::Slash() }

          # TODO: Add a link to the library page IF implemented.
          BreadcrumbLink(href: "#") { @library.name }

          BreadcrumbSeparator { Radix::Slash() }

          # TODO: Add a link to the category page IF implemented.
          BreadcrumbLink(href: "#") { @book.category.name }
        end
      end
    end
  end

  def title = Heading(level: "1", class: "max-sm:text-2xl line-clamp-3 sm:line-clamp-2") { @book.title }

  def author
    Text(size: "1", weight: "muted", class: "flex gap-x-1") do
      Bootstrap::Feather(class: "size-4")

      plain @book.author.name
    end
  end

  def content
    TopControls(book: @book, files: @files)

    div(class: "flex-1 flex justify-center gap-2 sm:gap-4 min-h-0") do
      txt_content
      pdf_content
    end

    BottomControls(book: @book, files: @files, current_file: @file)
  end

  def txt_content
    Card(
      class: "sm:max-w-1/2 flex-1 flex flex-col",
      data: {
        top_controls_target: "txtContent"
      }
    ) do
      CardContent(
        id: "txt-content",
        class: "flex-1 p-4 overflow-y-auto",
        data: {
          pdf_viewer_target: "content",
          top_controls_target: "content"
        }) do
        simple_format @page.content
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
