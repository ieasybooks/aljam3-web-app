module Mcp
  module Readers
    class Catalog < Base
      def books
        records, pagination = collection(
          PublicCatalog.books(book_filters).includes(:author, :category, :library).order(:title, :id),
          filters: book_filters
        )
        { books: records.map { |record| serializer.book(record) }, pagination: }
      end

      def book
        record = PublicCatalog.books.includes(:author, :category, :library).find(params.fetch(:id))
        files, pagination = browse(record.files)
        first_pages = Page.where(book_file_id: files.map(&:id)).group(:book_file_id).minimum(:number)
        { book: serializer.book(record), files: files.map { |file| serializer.file(file).merge(first_page_number: first_pages[file.id]) }, pagination: }
      end

      def authors
        records, pagination = collection(PublicCatalog.authors.order(:name, :id))
        { authors: records.map { |record| serializer.author(record) }, pagination: }
      end

      def categories
        records, pagination = collection(Category.order(:name, :id))
        { categories: records.map { |record| serializer.category(record) }, pagination: }
      end

      def libraries
        records, pagination = browse(Library.order(:name, :id))
        { libraries: records.map { |record| serializer.library(record) }, pagination: }
      end
    end
  end
end
