class Components::AuthorCard < Components::Base
  def initialize(author:)
    @author = author
  end

  def view_template
    Card do
      CardHeader(class: "p-4") do
        CardTitle(class: "line-clamp-1") do
          a(href: author_path(@author.id), data: { turbo_frame: "_top" }) do
            safe (process_meilisearch_highlights(@author.formatted&.[]("name")) || @author.name)
          end
        end
      end

      CardContent(class: "flex justify-between items-center p-4 border-t") do
        div(class: "flex") do
          Text(size: "1", weight: "muted") do
            plain t(".books")
            plain ": "
            plain @author.books_count
          end
        end

        Link(href: author_path(@author.id), variant: :outline, size: :sm, icon: true, data: { turbo_frame: "_top" }) do
          Hero::ArrowSmallRight(variant: :solid, class: "size-3.5 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
