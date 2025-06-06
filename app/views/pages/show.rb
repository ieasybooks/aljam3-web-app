class Views::Pages::Show < Views::Base
  def initialize(page:)
    @page = page
  end

  def page_title = t(".title", title: @page.file.book.title)

  def view_template
  end
end
