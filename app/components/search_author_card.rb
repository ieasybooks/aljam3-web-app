class Components::SearchAuthorCard < Components::Base
  def initialize(author:, index:, search_query_id:)
    @author = author
    @index = index
    @search_query_id = search_query_id
  end

  def view_template
    Card(class: "relative") do
      div(class: "absolute top-0 left-0 p-2 border-b border-r rounded-br-xl") do
        Bootstrap::Feather(class: "size-4 text-muted-foreground")
      end

      CardHeader(class: "p-4") do
        CardTitle(class: "line-clamp-1") do
          a(href: author_path(@author.id, i: @index, qid: @search_query_id), target: "_blank") do
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

        Link(href: author_path(@author.id, i: @index, qid: @search_query_id), variant: :outline, size: :sm, icon: true, target: "_blank") do
          Hero::ArrowSmallRight(variant: :solid, class: "size-3.5 rtl:transform rtl:-scale-x-100")
        end
      end
    end
  end
end
