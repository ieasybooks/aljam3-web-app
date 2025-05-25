class Views::Pages::Home < Views::Base
  def page_title = t(".title")

  def view_template
    h1 { page_title }
  end
end
