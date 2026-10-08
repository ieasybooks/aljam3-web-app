module Mcp
  module Readers
    class Base
      class InvalidParameter < StandardError; end

      def initialize(parameters:, url_base:)
        @params = parameters
        @serializer = Serializer.new(url_base:)
      end

      private

      attr_reader :params, :serializer

      def page = params.fetch(:page, 1)
      def per_page = params.fetch(:per_page, 10)
      def book_filters = params.slice(:author_id, :category_id, :library_id)

      def pagination(next_page)
        limit_reached = next_page.present? && next_page > 100
        { page:, per_page:, next_page: (next_page unless limit_reached), limit_reached: }
      end

      def browse(scope)
        records = scope.offset((page - 1) * per_page).limit(per_page + 1).to_a
        next_page = page + 1 if records.size > per_page
        [ records.first(per_page), pagination(next_page) ]
      end

      def collection(scope, filters: {})
        return browse(scope) unless params[:q]

        result = CatalogSearch.call(scope:, query: params.fetch(:q), page:, per_page:, filters:)
        [ result.records, pagination(result.next_page) ]
      end
    end
  end
end
