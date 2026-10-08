class PublicCatalog
  def self.authors = Author.where(hidden: false)

  def self.books(filters = {})
    Book.where(hidden: false, author_id: authors.select(:id)).where(filters)
  end

  def self.files = BookFile.where(book_id: books.select(:id))
  def self.pages = Page.where(book_file_id: files.select(:id))
end
