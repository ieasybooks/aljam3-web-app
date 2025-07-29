class AuthorCardComponentPreview < Lookbook::Preview
  def default
    render(Components::AuthorCard.new(author: Author.first))
  end
end
