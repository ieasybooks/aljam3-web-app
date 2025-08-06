class Views::Books::Index < Views::Base
  def initialize(books:, pagy:)
    @books = books
    @pagy = pagy
  end

  def head
    meta name: "turbo-refresh-method", content: "morph"
    meta name: "turbo-refresh-scroll", content: "preserve"
  end

  def page_title = t(".title")
  def description = t(".description")
  def keywords = t(".keywords")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      div(class: "flex max-sm:flex-col max-sm:space-y-4 justify-between items-top mb-4") do
        Heading(level: 1, class: "font-[Inter] rtl:font-[Cairo]") { page_title }

        InlineSearchForm(action: books_path)
      end

      BooksList(books: @books, pagy: @pagy)
    end
  end
end
