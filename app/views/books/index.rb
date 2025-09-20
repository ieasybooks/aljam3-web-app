class Views::Books::Index < Views::Base
  def initialize(books:, pagy:)
    @books = books
    @pagy = pagy
  end

  def page_title = t(".title")
  def description = t(".description")
  def keywords = t(".keywords")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      div(class: "flex max-sm:flex-col max-sm:space-y-4 justify-between items-top mb-4") do
        Heading(level: 1, class: "font-[Cairo]") { page_title } unless hotwire_native_app?

        # Search and favorites container
        div(class: "flex items-center space-x-4 sm:w-1/3") do
          div(class: "flex-1") do
            InlineSearchForm(action: books_path)
          end

          if user_signed_in?
            FavoritesToggle(user: current_user, active: params[:favorites] == "true")
          end
        end
      end

      BooksList(books: @books, pagy: @pagy)
    end
  end
end
