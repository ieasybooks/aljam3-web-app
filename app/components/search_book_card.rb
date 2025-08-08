# frozen_string_literal: true

class Components::SearchBookCard < Components::Base
  def initialize(book:, index:, search_query_id:)
    @book = book
    @index = index
    @search_query_id = search_query_id
  end

  def view_template
    Card(class: "relative") do
      div(class: "absolute top-0 end-0 p-2 border-b border-s rounded-es-xl") do
        Hero::BookOpen(variant: :outline, class: "size-4 text-muted-foreground")
      end

      CardHeader(class: "p-4") do
        a(href: category_path(@book.category.id), data: { turbo_frame: "_top" }) do
          Badge(variant: :neutral, size: :sm, class: "mb-1 w-fit") { @book.category.name }
        end

        CardTitle(class: "line-clamp-3 sm:line-clamp-2 leading-6") do
          a(href: book_path(@book.id, i: @index, qid: @search_query_id), target: "_blank") do
            safe (process_meilisearch_highlights(@book.formatted&.[]("title")) || @book.title)
          end
        end

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          a(href: author_path(@book.author.id), data: { turbo_frame: "_top" }) { @book.author.name }
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

        Link(
          href: book_path(@book.id, i: @index, qid: @search_query_id),
          variant: :outline,
          size: :sm,
          target: "_blank"
        ) do
          t(".book_page")
        end
      end
    end
  end
end
