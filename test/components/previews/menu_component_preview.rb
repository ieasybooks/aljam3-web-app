class MenuComponentPreview < Lookbook::Preview
  def default
    render Components::Menu.new
  end

  def on_pages_show
    render Components::Menu.new(controller_name: "pages", action_name: "show")
  end
end
