class SearchPageCardComponentPreview < Lookbook::Preview
  def default
    render Components::SearchPageCard.new(page: Page.first, index: 1, search_query_id: 1)
  end
end
