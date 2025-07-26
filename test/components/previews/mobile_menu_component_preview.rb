class MobileMenuComponentPreview < Lookbook::Preview
  def default
    render Components::MobileMenu.new
  end

  def on_pages_show
    render Components::MobileMenu.new(controller_name: "pages", action_name: "show")
  end
end
