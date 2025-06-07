# frozen_string_literal: true

class Components::SearchBookCard < Components::Base
  def initialize(book:)
    @book = book
  end

  def view_template
    Card(class: "relative") do
      div(class: "absolute top-0 left-0 p-2 border-b border-r rounded-br-xl") do
        Hero::BookOpen(variant: :outline, class: "size-6 text-muted-foreground")
      end

      CardHeader(class: "p-4") do
        Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @book.category }
        CardTitle { safe (@book.formatted["title"] || @book.title) }

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          plain @book.author
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

                plain @book.pages
              end
            end

            TooltipContent(class: "delay-100") { Text(size: "1") { t("pages_text") } }
          end
        end

        Link(href: book_path(@book), variant: :outline, size: :sm, target: "_top") { t(".book_page") }
      end
    end
  end
end
