class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
    @file = @page.file
    @book = @file.book
    @library = @book.library

    @files = @book.files
  end

  def page_title = t(".title", title: @page.file.book.title)
  def no_navbar = true

  def view_template
    div(
      class: "flex flex-col h-screen sm:container px-2 sm:px-4 py-2 sm:py-4 space-y-2 sm:space-y-4",
      data: {
        controller: "pdf-reader top-controls bottom-controls",
        pdf_reader_book_id_value: @book.id,
        top_controls_book_title_value: @book.title,
        top_controls_copy_text_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_download_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
        top_controls_copy_image_button_done_status_value: capture { render Lucide::Check(class: "size-5") }
      }
    ) do
      header
      content
    end
  end

  private

  def header
    div(class: "flex items-center justify-between") do
      div(class: "flex flex-col items-start gap-y-1") do
        breadcrumb
        title
        author
      end
    end
  end

  def breadcrumb
    Breadcrumb do
      BreadcrumbList do
        BreadcrumbLink(href: root_path) { t("aljam3") }

        BreadcrumbSeparator { Radix::Slash() }

        # TODO: Add a link to the library page IF implemented.
        BreadcrumbLink(href: "#") { @library.name }

        BreadcrumbSeparator { Radix::Slash() }

        # TODO: Add a link to the category page IF implemented.
        BreadcrumbLink(href: "#") { @book.category }
      end
    end
  end

  def title = Heading(level: "1", class: "max-sm:text-2xl line-clamp-3 sm:line-clamp-2") { @book.title }

  def author
    Text(size: "1", weight: "muted", class: "flex gap-x-1") do
      Bootstrap::Feather(class: "size-4")

      plain @book.author
    end
  end

  def content
    TopControls(files: @files)

    div(class: "flex-1 flex justify-center gap-2 sm:gap-4 min-h-0") do
      txt_content
      pdf_content
    end

    BottomControls(book: @book, files: @files, current_file: @file)
  end

  def txt_content
    # Dark background color is similar to the PDF's viewer background color.
    div(
      class: "sm:max-w-1/2 flex-1 bg-gray-100 dark:bg-[#2a2a2e] rounded-lg flex flex-col",
      data: {
        top_controls_target: "txtContent"
      }
    ) do
      div(id: "txt-content", class: "flex-1 p-4 overflow-y-auto", data: { top_controls_target: "content" }) do
        simple_format @page.content
      end
    end
  end

  def pdf_content
    div(class: "sm:max-w-1/2 flex-1 rounded-lg overflow-y-auto", data: { top_controls_target: "pdfContent" }) do
      iframe(
        src: pdfjs_path(file: @file.pdf_url, anchor: "page=#{@page.number}"),
        class: "w-full h-full",
        data: {
          pdf_reader_target: "iframe",
          top_controls_target: "iframe",
          bottom_controls_target: "iframe"
        }
      )
    end
  end
end
