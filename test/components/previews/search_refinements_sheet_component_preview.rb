class SearchRefinementsSheetComponentPreview < Lookbook::Preview
  def default
    render Components::SearchRefinementsSheet.new(
      libraries: proc { Library.pluck(:id, :name) },
      categories: proc { Category.pluck(:id, :name, :books_count) }
    )
  end
end
