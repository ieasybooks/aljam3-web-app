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
        Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @book.category.name }
        CardTitle { safe (process_meilisearch_highlights(@book.formatted["title"]) || @book.title) }

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          plain @book.author.name
        end
      end

      CardContent(class: "flex justify-between items-center p-4 border-t") do
        div(class: "flex") do
          if @book.volumes != -1
            Text(size: "1", weight: "muted") do
              plain t("volumes")
              plain ": "
              plain @book.volumes
            end
          else
            Text(size: "1", weight: "muted") do
              plain t("files")
              plain ": "
              plain @book.files_count
            end
          end

          Separator(orientation: :vertical, class: "h-4 ms-1.5 me-1.5")

          Text(size: "1", weight: "muted") do
            plain t("pages_text")
            plain ": "
            plain @book.pages_count
          end
        end

        Link(href: book_path(@book), variant: :outline, size: :sm, target: "_top") { t(".book_page") }
      end
    end
  end
end
