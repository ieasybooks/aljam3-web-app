class SearchAuthorCardComponentPreview < Lookbook::Preview
  def default
    render(Components::SearchAuthorCard.new(author: Author.first, index: 1, search_query_id: 1))
  end
end
