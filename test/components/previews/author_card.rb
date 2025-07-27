class Previews::AuthorCard < ViewComponent::Preview
  def default
    render(Components::AuthorCard.new(author: Author.first))
  end
end
