class BookCardComponentPreview < Lookbook::Preview
  def default
    render Components::BookCard.new(book: Book.first)
  end

  def without_category
    render Components::BookCard.new(book: Book.first, show_category: false)
  end

  def with_no_volumes
    render Components::BookCard.new(book: Book.first.tap { it.volumes = -1 })
  end
end
