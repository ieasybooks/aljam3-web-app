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
    div(class: "relative", data: { top_controls_target: "header" }) do
      div(class: "flex items-center justify-between") do
        div(class: "flex flex-col items-start gap-y-1") do
          breadcrumb
          title
          author
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
    TopControls(book: @book, files: @files, file: @file, page: @page)

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
      turbo_frame_tag(
        :pdfjs_iframe,
        src: pdfjs_iframe_path(
          locale: nil,
          src: pdfjs_path(file: @file.pdf_url, locale: I18n.locale, anchor: "page=#{@page.number}")
        ),
        loading: :lazy,
        class: "w-full h-full flex justify-center items-center"
      ) do
        Tabler::Pdf(variant: :outline, class: "animate-pulse size-20")
      end
    end
  end
end
