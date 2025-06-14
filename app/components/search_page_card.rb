# frozen_string_literal: true

class Components::SearchPageCard < Components::Base
  def initialize(page:)
    @page = page
  end

  def view_template
    Card(class: "relative") do
      div(class: "absolute top-0 left-0 p-2.5 border-b border-r rounded-br-xl") do
        Lucide::FileText(class: "size-5.5 text-muted-foreground")
      end

      CardHeader(class: "p-4") do
        Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @page.file.book.category }
        CardTitle { @page.file.book.title }

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          plain @page.file.book.author
        end
      end

      CardContent() do
        div(
          class: "border-s border-s-5 ps-2",
          data: {
            controller: "read-more",
            read_more_more_text_value: t(".read_more"),
            read_more_less_text_value: t(".hide")
          }
        ) do
          p(class: "read-more-content", data: { read_more_target: "content" }) do
            raw safe @page.formatted["content"] || @page.content
          end

          button(class: "text-blue-500 text-sm cursor-pointer", data: { action: "read-more#toggle" }) { t(".read_more") }
        end
      end

      CardFooter(class: "flex justify-between items-center p-4 border-t") do
        div(class: "flex") do
          if @page.file.book.volumes != -1
            Tooltip do
              TooltipTrigger do
                Text(size: "1", weight: "muted", class: "flex gap-x-0.5 cursor-default") do
                  Tabler::Books(class: "size-4")

                  plain @page.file.book.volumes
                end
              end

              TooltipContent(class: "delay-100") { Text(size: "1") { t("volumes") } }
            end

            Separator(orientation: :vertical, class: "h-4 ms-2 me-1.5")
          end

          Tooltip do
            TooltipTrigger do
              Text(size: "1", weight: "muted", class: "flex gap-x-0.5 cursor-default") do
                Lucide::FileText(class: "size-4 p-px ps-0")

                plain @page.file.book.pages_count
              end
            end

            TooltipContent(class: "delay-100") { Text(size: "1") { t("pages_text") } }
          end
        end

        Link(href: book_file_page_path(@page.file.book, @page.file, @page), variant: :outline, size: :sm, target: "_top") { t(".show_page") }
      end
    end
  end
end
