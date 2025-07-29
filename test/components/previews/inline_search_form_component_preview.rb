class InlineSearchFormComponentPreview < Lookbook::Preview
  def default
    render Components::InlineSearchForm.new(action: authors_path)
  end
end
