class BookSearchFormComponentPreview < Lookbook::Preview
  def default
    render Components::BookSearchForm.new(book: Book.first)
  end
end
