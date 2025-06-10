# frozen_string_literal: true

class Components::Navbar < Components::Base
  def view_template
    header(class: "supports-backdrop-blur:bg-background/80 sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-2xl backdrop-saturate-200") do
      div(class: "px-2 sm:px-4 sm:container flex h-14 items-center justify-between") do
        div(class: "flex items-center") do
          MobileMenu(class: "md:hidden")

          Logo()

          Link(href: "", variant: :ghost, size: :lg, class: "hidden md:inline-block") { t(".home") }
        end

        div(class: "flex items-center gap-x-2 md:divide-x") do
          dark_mode_toggle
        end
      end
    end
  end

  private

  def dark_mode_toggle
    ThemeToggle do
      SetLightMode { Button(variant: :ghost, icon: true) { Lucide::Sun(class: "size-5") } }
      SetDarkMode { Button(variant: :ghost, icon: true) { Remix::MoonFill(class: "size-4.5") } }
    end
  end
end
