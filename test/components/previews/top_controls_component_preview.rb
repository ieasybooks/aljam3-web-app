class TopControlsComponentPreview < Lookbook::Preview
  def default
    render Components::TopControls.new(book: Book.first, files: Book.first.files)
  end
end
