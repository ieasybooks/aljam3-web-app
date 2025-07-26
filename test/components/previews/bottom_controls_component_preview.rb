class BottomControlsComponentPreview < Lookbook::Preview
  def default
    render Components::BottomControls.new(
      book: Book.first,
      files: Book.first.files,
      current_file: Book.first.files.first
    )
  end
end
