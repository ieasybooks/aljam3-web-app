# frozen_string_literal: true

class Components::Navbar < Components::Base
  def view_template
    header(class: "supports-backdrop-blur:bg-background/80 sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-2xl backdrop-saturate-200") do
      div(class: "px-2 sm:px-4 sm:container flex h-14 items-center justify-between") do
        div(class: "flex items-center") do
          MobileMenu(class: "md:hidden")

          Logo(class: "max-sm:ps-1")

          Link(href: root_path, variant: :ghost, size: :lg, class: "hidden md:inline-block") { t(".home") }
          Link(href: categories_path, variant: :ghost, size: :lg, class: "hidden md:inline-block") { t(".categories") }
        end

        div(class: "flex items-center gap-x-1") do
          if user_signed_in?
            Tooltip(placement: :bottom) do
              TooltipTrigger do
                Link(href: destroy_user_session_path, variant: :ghost, icon: true, data: { turbo_method: :delete }) do
                  Hero::ArrowLeftStartOnRectangle(class: "size-5 ltr:transform ltr:-scale-x-100")
                end
              end

              TooltipContent(class: "delay-100 max-sm:hidden") do
                Text { t(".sign_out") }
              end
            end
          end

          Tooltip(placement: :bottom) do
            TooltipTrigger do
              ContactDialog do
                Button(variant: :ghost, icon: true) do
                  Bootstrap::Mailbox(class: "size-5 rtl:transform rtl:-scale-x-100")
                end
              end
            end

            TooltipContent(class: "delay-100 max-sm:hidden") do
              Text { t(".contact_us") }
            end
          end

          Tooltip(placement: :bottom) do
            TooltipTrigger do
              theme_toggle
            end

            TooltipContent(class: "delay-100 max-sm:hidden") do
              Text { t(".theme") }
            end
          end
        end
      end
    end
  end

  private

  def theme_toggle
    ThemeToggle do
      SetLightMode { Button(variant: :ghost, icon: true) { Lucide::Sun(class: "size-5") } }
      SetDarkMode { Button(variant: :ghost, icon: true) { Remix::MoonFill(class: "size-4.5") } }
    end
  end
end
