class Views::Authors::Index < Views::Base
  def initialize(authors:, pagy:)
    @authors = authors
    @pagy = pagy
  end

  def page_title = t(".title")
  def description = t(".description")
  def keywords = t(".keywords")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      Heading(level: 1, class: "mb-4 font-[Cairo]") { page_title }

      AuthorsList(authors: @authors, pagy: @pagy)
    end
  end
end
