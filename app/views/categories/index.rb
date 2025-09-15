class Views::Categories::Index < Views::Base
  def initialize(categories:)
    @categories = categories
  end

  def page_title = t(".title")
  def description = t(".description")
  def keywords = t(".keywords")

  def view_template
    plain "user_signed_in?" if user_signed_in?

    cache [ I18n.locale, hotwire_native_app?, android_native_app?, ios_native_app? ], expires_in: 1.hour do
      div(class: "px-4 sm:px-4 py-4 sm:container") do
        Heading(level: 1, class: "mb-4 font-[Cairo]") { page_title } unless hotwire_native_app?

        @categories.each_with_index do |category, index|
          Separator(class: "my-2") unless index.zero?

          Link(href: category_path(category.id), class: "w-full px-3 py-5 text-foreground hover:bg-accent hover:no-underline") do
            div(class: "w-full flex justify-between") do
              Text(size: "4") { "#{index + 1}. #{category.name}" }
              Text(size: "4") { number_with_delimiter(category.books_count) }
            end
          end
        end
      end
    end
  end
end
