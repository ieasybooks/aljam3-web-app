class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
    @file = @page.file
    @book = @file.book
    @library = @book.library
  end

  def page_title = t(".title", title: @page.file.book.title)
  def no_navbar = true

  def view_template
    div(
      class: "flex flex-col h-screen sm:container px-2 sm:px-4 py-2 sm:py-4 space-y-2 sm:space-y-4",
      data: {
        controller: "book-page top-controls bottom-controls",
        book_page_book_id_value: @book.id,
        top_controls_copy_text_button_done_status_value: capture { render Lucide::Check(class: "size-5") },
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

  def title = Heading(level: "1") { @book.title }

  def author
    Text(size: "1", weight: "muted", class: "flex gap-x-1") do
      Bootstrap::Feather(class: "size-4")

      plain @book.author
    end
  end

  def content
    top_controls

    div(class: "flex-1 flex justify-center gap-2 sm:gap-4 min-h-0") do
      txt_content
      pdf_content
    end

    bottom_controls
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
          book_page_target: "iframe",
          top_controls_target: "iframe",
          bottom_controls_target: "iframe"
        }
      )
    end
  end

  def top_controls
    div(class: "flex items-center justify-between p-2 gap-x-2 overflow-x-auto rounded-lg bg-gray-100 dark:bg-[#2a2a2e]") do
      div(class: "flex items-center gap-x-2") do
        copy_text_button
        text_size_increase_button
        text_size_decrease_button
      end

      div(class: "flex items-center gap-x-2") do
        txt_content_only_button
        txt_and_pdf_content_button
        pdf_content_only_button
      end

      div(class: "flex items-center gap-x-2") do
        dummy_button
        dummy_button
        copy_image_button
      end
    end
  end

  def copy_text_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->top-controls#copyText",
            top_controls_target: "copyTextButton"
          }
        ) do
          Lucide::Copy(class: "size-5 rtl:transform rtl:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden") do
        Text { t(".copy_content") }
      end
    end
  end

  def text_size_increase_button
    Tooltip do
      TooltipTrigger do
        Button(variant: :outline, size: :md, icon: true, data: { action: "click->top-controls#textSizeIncrease" }) do
          Tabler::TextIncrease(variant: :outline, class: "size-5")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden") do
        Text { t(".text_size_increase") }
      end
    end
  end

  def text_size_decrease_button
    Tooltip do
      TooltipTrigger do
        Button(variant: :outline, size: :md, icon: true, data: { action: "click->top-controls#textSizeDecrease" }) do
          Tabler::TextDecrease(variant: :outline, class: "size-5")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden") do
        Text { t(".text_size_decrease") }
      end
    end
  end

  def txt_content_only_button
    Button(
      variant: :outline,
      size: :md,
      icon: true,
      data: {
        action: "click->top-controls#txtContentOnly",
        top_controls_target: "txtContentOnlyButton"
      }
    ) do
      Tabler::LayoutSidebarRightExpand(variant: :outline, class: "max-sm:hidden sm:block size-6")
      Bootstrap::FiletypeTxt(class: "max-sm:block sm:hidden size-5")
    end
  end

  def txt_and_pdf_content_button
    Button(
      variant: :outline,
      size: :md,
      icon: true,
      class: "max-sm:hidden",
      data: {
        action: "click->top-controls#txtAndPdfContent",
        top_controls_target: "txtAndPdfContentButton"
      }
    ) do
      Tabler::LayoutColumns(variant: :outline, class: "size-6")
    end
  end

  def pdf_content_only_button
    Button(
      variant: :outline,
      size: :md,
      icon: true,
      data: {
        action: "click->top-controls#pdfContentOnly",
        top_controls_target: "pdfContentOnlyButton"
      }
    ) do
      Tabler::LayoutSidebarRightCollapse(variant: :outline, class: "max-sm:hidden sm:block size-6")
      Bootstrap::FiletypePdf(class: "max-sm:block sm:hidden size-5")
    end
  end

  def copy_image_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->top-controls#copyImage",
            top_controls_target: "copyImageButton"
          }
        ) do
          Lucide::Images(class: "size-5 ltr:transform ltr:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden") do
        Text { t(".copy_image") }
      end
    end
  end

  def bottom_controls
    div(class: "flex items-center justify-center p-2 gap-x-2 overflow-x-auto rounded-lg bg-gray-100 dark:bg-[#2a2a2e]") do
      first_page_button
      previous_page_button
      next_page_button
      last_page_button
    end
  end

  def first_page_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->bottom-controls#firstPage",
            bottom_controls_target: "firstPageButton"
          }) do
          Hero::ChevronDoubleLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden", data: { bottom_controls_target: "firstPageButtonTooltip" }) do
        Text { t(".first_page") }
      end
    end
  end

  def previous_page_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->bottom-controls#previousPage",
            bottom_controls_target: "previousPageButton"
          }
        ) do
          Hero::ChevronLeft(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden", data: { bottom_controls_target: "previousPageButtonTooltip" }) do
        Text { t(".previous_page") }
      end
    end
  end

  def next_page_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->bottom-controls#nextPage",
            bottom_controls_target: "nextPageButton"
          }
        ) do
          Hero::ChevronRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden", data: { bottom_controls_target: "nextPageButtonTooltip" }) do
        Text { t(".next_page") }
      end
    end
  end

  def last_page_button
    Tooltip do
      TooltipTrigger do
        Button(
          variant: :outline,
          size: :md,
          icon: true,
          data: {
            action: "click->bottom-controls#lastPage",
            bottom_controls_target: "lastPageButton"
          }
        ) do
          Hero::ChevronDoubleRight(variant: :solid, class: "size-5 rtl:transform rtl:-scale-x-100")
        end
      end

      TooltipContent(class: "delay-100 max-sm:hidden", data: { bottom_controls_target: "lastPageButtonTooltip" }) do
        Text { t(".last_page") }
      end
    end
  end

  def dummy_button = Button(variant: :link, size: :md, icon: true, class: "max-sm:hidden pointer-events-none")
end
