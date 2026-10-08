module Mcp
  class Serializer
    include Rails.application.routes.url_helpers

    def initialize(url_base:)
      @url_base = url_base
    end

    def book(record)
      {
        id: record.id, title: record.title, author: author(record.author), category: category(record.category),
        library: library(record.library), pages_count: record.pages_count, files_count: record.files_count,
        volumes: (record.volumes if record.volumes.positive?), url: url(book_path(book_id: record.id, locale: I18n.locale))
      }
    end

    def author(record)
      { id: record.id, name: record.name, url: url(author_path(record.id, locale: I18n.locale)) }
    end

    def category(record)
      { id: record.id, name: record.name, url: url(category_path(record.id, locale: I18n.locale)) }
    end

    def library(record)
      { id: record.id, name: record.name }
    end

    def file(record)
      {
        id: record.id, name: record.name, pages_count: record.pages_count,
        url: url(book_file_path(book_id: record.book_id, file_id: record.id, locale: I18n.locale)),
        download_urls: { pdf: record.pdf_url, txt: record.txt_url, docx: record.docx_url }
      }
    end

    def page(record)
      {
        id: record.id, file_id: record.book_file_id, file_name: record.file.name, page_number: record.number,
        book: book(record.file.book),
        url: url(book_file_page_path(book_id: record.file.book_id, file_id: record.book_file_id, page_number: record.number, locale: I18n.locale)),
        pdf_url: "#{record.file.pdf_url.split('#').first}#page=#{record.number}"
      }
    end

    private

    def url(path) = "#{@url_base}#{path}"
  end
end
