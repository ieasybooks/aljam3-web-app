# frozen_string_literal: true

class Components::BookCard < Components::Base
  def initialize(book:, show_category: true)
    @book = book
    @show_category = show_category
  end

  def view_template
    Card do
      CardHeader(class: "p-4") do
        if @show_category
          a(href: category_path(@book.category.id), data: { turbo_frame: "_top" }) do
            Badge(variant: :neutral, size: :sm, class: "mb-4 w-fit") { @book.category.name }
          end
        end

        CardTitle(class: "line-clamp-1") { a(href: book_path(@book.id), data: { turbo_frame: "_top" }) { @book.title } }

        CardDescription(class: "flex items-center gap-x-1") do
          Bootstrap::Feather(class: "size-4")

          span(class: "line-clamp-1") { @book.author.name }
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
