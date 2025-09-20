class Views::Favorites::Index < Views::Base
  def initialize(favorites:, pagy:)
    @favorites = favorites
    @pagy = pagy
  end

  def page_title = t(".title")
  def description = t(".description")

  def view_template
    div(class: "px-4 sm:px-4 py-4 sm:container") do
      div(class: "flex items-center justify-between mb-6") do
        Heading(level: 1, class: "font-[Cairo]") { page_title }

        link_to(
          books_path,
          class: "inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
        ) do
          Hero::ArrowLeft(class: "size-4 mr-2")
          t(".back_to_books")
        end
      end

      if @favorites.any?
        div(class: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6") do
          @favorites.each do |favorite|
            BookCard(book: favorite.book)
          end
        end
      else
        # Empty state
        div(class: "text-center py-12") do
          Hero::Heart(class: "size-16 mx-auto text-gray-300 mb-4")
          Heading(level: 2, class: "text-xl text-gray-500 mb-2") { t(".empty_title") }
          p(class: "text-gray-400 mb-6") { t(".empty_description") }

          link_to(
            books_path,
            class: "inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700"
          ) do
            Hero::BookOpen(class: "size-5 mr-2")
            t(".browse_books")
          end
        end
      end
    end
  end
end
