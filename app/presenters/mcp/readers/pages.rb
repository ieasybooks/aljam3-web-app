module Mcp
  module Readers
    class Pages < Base
      def show
        record = PublicCatalog.pages.includes(file: { book: %i[author category library] })
          .find_by!(book_file_id: params.fetch(:file_id), number: params.fetch(:page_number))
        offset = params.fetch(:offset, 0)
        raise InvalidParameter, "offset exceeds this page's total_chars." if offset > record.content.length

        content = record.content.slice(offset, params.fetch(:max_chars, 6_000)).to_s
        following_offset = offset + content.length

        {
          page: serializer.page(record),
          text: { content:, offset:, total_chars: record.content.length, next_offset: (following_offset if following_offset < record.content.length) },
          navigation: {
            previous_page_number: record.file.pages.where(number: ...record.number).maximum(:number),
            next_page_number: record.file.pages.where("number > ?", record.number).minimum(:number)
          }
        }
      end
    end
  end
end
