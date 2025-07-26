class SearchFormComponentPreview < Lookbook::Preview
  def default
    render Components::SearchForm.new(
      libraries: proc { Library.pluck(:id, :name) },
      categories: proc { Category.pluck(:id, :name, :books_count) }
    )
  end
end
