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
      div(class: "flex max-sm:flex-col max-sm:space-y-4 justify-between items-top mb-4") do
        unless hotwire_native_app?
          div do
            Heading(level: 1, class: "mb-2 font-[Cairo]") { @category.name }
            Text { "#{t(".books")}: #{number_with_delimiter(@category.books_count)}" }
          end
        end

        InlineSearchForm(action: category_path(@category))
      end

      CategoryBooksList(category: @category, books: @books, pagy: @pagy)
    end
  end
end
