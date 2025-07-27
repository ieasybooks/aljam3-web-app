class Views::Categories::Show < Views::Base
  def initialize(category:, books:, pagy:)
    @category = category
    @books = books
    @pagy = pagy
  end

  def page_title = @category.name
  def description = "#{@category.name} - #{t(".books")}: #{number_with_delimiter(@category.books_count)}"
  def keywords = [ @category.name ]

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      Heading(level: 1, class: "mb-2 font-[Cairo]") { @category.name }
      Text(class: "mb-3") { "#{t(".books")}: #{number_with_delimiter(@category.books_count)}" }

      CategoryBooksList(category: @category, books: @books, pagy: @pagy)
    end
  end
end
