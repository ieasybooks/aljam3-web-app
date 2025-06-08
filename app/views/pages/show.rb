class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
    @file = @page.file
    @book = @file.book
    @library = @book.library
  end

  def page_title = t(".title", title: @page.file.book.title)

  def view_template
    div(
      class: "flex flex-col h-[calc(100vh-57px)] sm:container px-2 sm:px-4 py-2 sm:py-4 space-y-2 sm:space-y-4",
      data: {
        controller: "book-page",
        book_page_book_id_value: @book.id
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
        # TODO: Add a link to the library page IF implemented.
        BreadcrumbLink(href: "#") { @library.name }

        BreadcrumbSeparator { Radix::Slash() }

        # TODO: Add a link to the category page IF implemented.
        BreadcrumbLink(href: "#") { @book.category }
      end
    end
  end

  def title = Heading(level: "1") { @book.title }

  def author
    Text(size: "1", weight: "muted", class: "flex gap-x-1") do
      Bootstrap::Feather(class: "size-4")

      plain @book.author
    end
  end

  def content
    div(class: "flex-1 flex gap-2 sm:gap-4 min-h-0") do
      txt_content
      pdf_content
    end
  end

  def txt_content
    # Dark background color is similar to the PDF's viewer background color.
    div(
      id: "txt-content",
      class: "flex-1 bg-gray-100 dark:bg-[#2a2a2e] rounded-lg p-4 overflow-y-auto",
    ) do
      simple_format @page.content
    end
  end

  def pdf_content
    div(class: "flex-1 rounded-lg overflow-y-auto") do
      iframe(
        src: pdfjs_path(file: @file.pdf_url, anchor: "page=#{@page.number}"),
        class: "w-full h-full",
        data: { book_page_target: "iframe" }
      )
    end
  end
end
