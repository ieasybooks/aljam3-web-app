class Views::Authors::Show < Views::Base
  def initialize(author:, books:, pagy:)
    @author = author
    @books = books
    @pagy = pagy
  end

  def head
    meta name: "turbo-refresh-method", content: "morph"
    meta name: "turbo-refresh-scroll", content: "preserve"
  end

  def page_title = @author.name
  def description = "#{@author.name} - #{t(".books")}: #{number_with_delimiter(@author.books_count)}"
  def keywords = [ @author.name ]

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      div(class: "flex max-sm:flex-col max-sm:space-y-4 justify-between items-top mb-4") do
        div do
          Heading(level: 1, class: "mb-2 font-[Cairo]") { @author.name }
          Text { "#{t(".books")}: #{number_with_delimiter(@author.books_count)}" }
        end

        InlineSearchForm(action: author_path(@author))
      end

      AuthorBooksList(author: @author, books: @books, pagy: @pagy)
    end
  end
end
