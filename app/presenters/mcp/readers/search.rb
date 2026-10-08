module Mcp
  module Readers
    class Search < Base
      EXCERPT_LENGTH = 1_000

      def index
        books = PublicCatalog.books(book_filters)
        books = books.where(id: params[:book_id]) if params[:book_id]
        scope = Page.where(book_file_id: BookFile.where(book_id: books.select(:id)).select(:id))
          .includes(file: { book: %i[author category library] })
        result = CatalogSearch.call(
          scope:, query: params.fetch(:q), page:, per_page:, filters: book_filters.merge(params.slice(:book_id))
        )
        {
          results: result.records.map { |record| search_hit(record, result.matches.fetch(record.id.to_s)) },
          pagination: pagination(result.next_page)
        }
      end

      private

      def search_hit(record, matches)
        # Meilisearch positions are UTF-8 byte offsets; get_page uses character offsets.
        # Prefer a substantial match over a common short prefix such as Arabic "ال".
        match = matches.fetch("content", []).max_by { |position| position.fetch("length") }
        byte_offset = match&.fetch("start") || 0
        match_offset = record.content.byteslice(0, byte_offset).scrub.length
        offset = [ [ match_offset - 200, 0 ].max, [ record.content.length - EXCERPT_LENGTH, 0 ].max ].min
        excerpt = record.content.slice(offset, EXCERPT_LENGTH)
        serializer.page(record).merge(excerpt:, excerpt_offset: offset, excerpt_truncated: excerpt.length < record.content.length)
      end
    end
  end
end
