# frozen_string_literal: true

class Components::SearchPageCard < Components::Base
  def initialize(page:, index:, search_query_id:)
    @page = page
    @index = index
    @search_query_id = search_query_id
  end

  def view_template
    Card(class: "relative") do
      div(class: "absolute top-0 end-0 p-2 border-b border-s rounded-es-xl") do
        Lucide::FileText(class: "size-4 text-muted-foreground")
      end

      CardHeader(class: "p-4") do
        a(href: category_path(@page.file.book.category.id)) do
          Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @page.file.book.category.name }
        end

        CardTitle(class: "line-clamp-3 sm:line-clamp-2 leading-6") do
          a(
            href: book_file_page_path(@page.file.book.id, @page.file.id, @page.number, i: @index, qid: @search_query_id),
            target: "_blank"
          ) do
            @page.file.book.title
          end
        end

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          a(href: author_path(@page.file.book.author), data: { turbo_frame: "_top" }) { @page.file.book.author.name }
        end
      end

      CardContent() do
        div(
          class: "ltr:border-e rtl:border-s ltr:border-e-5 rtl:border-s-5 ltr:pe-2 rtl:ps-2 text-right",
          data: {
            controller: "read-more",
            read_more_more_text_value: t(".read_more"),
            read_more_less_text_value: t(".hide")
          }
        ) do
          p(class: "read-more-content font-[Kitab] leading-7", data: { read_more_target: "content" }) do
            raw safe process_meilisearch_highlights(@page.formatted&.[]("content")) || @page.content
          end

          button(class: "text-primary text-sm cursor-pointer", data: { action: "read-more#toggle" }) { t(".read_more") }
        end
      end

      CardFooter(class: "flex justify-between items-center p-4 border-t") do
        div(class: "flex") do
          Text(size: "1", weight: "muted") do
            plain t(".file_name")
            plain ": "
            plain @page.file.name
          end

          Separator(orientation: :vertical, class: "h-4 ms-1.5 me-1.5")

          Text(size: "1", weight: "muted") do
            plain t("page")
            plain ": "
            plain @page.number
          end
        end

        Link(
          href: book_file_page_path(@page.file.book.id, @page.file.id, @page.number, i: @index, qid: @search_query_id),
          variant: :outline,
          size: :sm,
          target: "_blank"
        ) { t(".show_page") }
      end
    end
  end
end
