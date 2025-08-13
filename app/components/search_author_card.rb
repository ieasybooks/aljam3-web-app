class Components::SearchAuthorCard < Components::Base
  def initialize(author:, index:, search_query_id:)
    @author = author
    @index = index
    @search_query_id = search_query_id
  end

  def view_template
    Card(class: "relative") do
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

        Link(href: author_path(@author.id, i: @index, qid: @search_query_id), variant: :outline, size: :sm, target: "_blank") do
          t(".author_page")
        end
      end
    end
  end
end
