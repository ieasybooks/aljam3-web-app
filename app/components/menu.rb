# frozen_string_literal: true

class Components::Menu < Components::Base
  def view_template
    div(class: "pb-4") do
      menu_link(path: root_path, text: t("navbar.home"), icon: Hero::Home.new(variant: :outline, class: "size-5"))
      dark_mode_toggle if controller_name == "pages" && action_name == "show"
    end
  end

  private

  def menu_link(path:, text:, icon:)
    Link(
      variant: :link,
      href: path,
      class: [
        "flex items-center justify-start gap-x-2",
        (path == request.path ? "text-foreground font-medium" : "text-muted-foreground")
      ]
    ) do
      render icon

      plain text
    end
  end

  def dark_mode_toggle
    ThemeToggle do
      SetLightMode do
        Button(variant: :link, class: "flex items-center gap-x-2 text-muted-foreground") do
          Lucide::Sun(class: "size-5")

          plain t(".light_mode")
        end
      end

      SetDarkMode do
        Button(variant: :link, class: "flex items-center gap-x-2 text-muted-foreground") do
          Remix::MoonFill(class: "size-5")

          plain t(".dark_mode")
        end
      end
    end
  end
end
