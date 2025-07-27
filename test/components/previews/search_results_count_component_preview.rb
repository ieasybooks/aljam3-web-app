class SearchResultsCountComponentPreview < Lookbook::Preview
  def default
    render Components::SearchResultsCount.new(count: 1000)
  end
end
