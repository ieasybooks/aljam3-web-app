class SearchBookCardComponentPreview < Lookbook::Preview
  def default
    render Components::SearchBookCard.new(book: Book.first, index: 1, search_query_id: 1)
  end
end
