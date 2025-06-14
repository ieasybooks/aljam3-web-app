# frozen_string_literal: true

class Components::CarouselBookCard < Components::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    Card() do
      CardHeader(class: "p-4") do
        Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @book.category }
        CardTitle(class: "line-clamp-1") { @book.title }

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          span(class: "line-clamp-1") { @book.author }
        end
      end

      CardContent(class: "flex justify-between items-center p-4 border-t") do
        div(class: "flex") do
          if @book.volumes != -1
            Tooltip do
              TooltipTrigger do
                Text(size: "1", weight: "muted", class: "flex gap-x-0.5 cursor-default") do
                  Tabler::Books(class: "size-4")

                  plain @book.volumes
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

                plain @book.pages_count
              end
            end

            TooltipContent(class: "delay-100") { Text(size: "1") { t("pages_text") } }
          end
        end

        Link(href: book_path(@book), variant: :outline, size: :sm, icon: true) do
          Hero::ArrowSmallRight(variant: :solid, class: "size-3.5 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
