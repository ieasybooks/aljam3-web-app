# frozen_string_literal: true

class Components::BookCard < Components::Base
  def initialize(book:, show_category: true, show_author: true)
    @book = book
    @show_category = show_category
    @show_author = show_author
  end

  def view_template
    Card do
      CardHeader(class: "p-4") do
        div(class: "flex justify-between items-start") do
          div(class: "flex-1 flex flex-col") do
            if @show_category
              a(href: category_path(@book.category.id), class: "w-fit mb-4", data: { turbo_frame: "_top" }) do
                Badge(variant: :neutral, size: :sm) { @book.category.name }
              end
            end

            CardTitle(class: "line-clamp-1") do
              a(href: book_path(@book.id), data: { turbo_frame: "_top" }) do
                safe (process_meilisearch_highlights(@book.formatted&.[]("title")) || @book.title)
              end
            end

            if @show_author
              CardDescription(class: "flex items-center gap-x-1") do
                Bootstrap::Feather(class: "size-4")

                span(class: "line-clamp-1") { a(href: author_path(@book.author.id), data: { turbo_frame: "_top" }) { @book.author.name } }
              end
            end
          end

          div(class: "flex-shrink-0") do
            render Components::FavoriteButton.new(book: @book)
          end
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

        Link(href: book_path(@book.id), variant: :outline, size: :sm, icon: true, data: { turbo_frame: "_top" }) do
          Hero::ArrowSmallRight(variant: :solid, class: "size-3.5 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
