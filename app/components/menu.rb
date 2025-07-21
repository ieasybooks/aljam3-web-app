# frozen_string_literal: true

class Components::Menu < Components::Base
  def view_template
    div(class: "pb-4") do
      menu_link(path: root_path, text: t("navbar.home"), icon: Hero::Home.new(variant: :outline, class: "size-5"))
      menu_link(path: categories_path, text: t("navbar.categories"), icon: Lucide::LayoutGrid.new(variant: :outline, class: "size-5"))

      if controller_name == "pages" && action_name == "show"
        ContactDialog do
          Button(variant: :link, class: "flex items-center gap-x-2 text-muted-foreground") do
            Bootstrap::Mailbox(class: "size-5 ltr:transform ltr:-scale-x-100")

            plain t("navbar.contact_us")
          end
        end

        language_toggle
        theme_toggle
      end
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

  def language_toggle
    LanguageToggle()
  end

  def theme_toggle
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
