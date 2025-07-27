class Views::Authors::Show < Views::Base
  def initialize(author:, books:, pagy:)
    @author = author
    @books = books
    @pagy = pagy
  end

  def page_title = @author.name
  def description = "#{@author.name} - #{t(".books")}: #{number_with_delimiter(@author.books_count)}"
  def keywords = [ @author.name ]

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      Heading(level: 1, class: "mb-2 font-[Cairo]") { @author.name }
      Text(class: "mb-3") { "#{t(".books")}: #{number_with_delimiter(@author.books_count)}" }

      AuthorBooksList(author: @author, books: @books, pagy: @pagy)
    end
  end
end
