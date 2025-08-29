# frozen_string_literal: true

class Components::Navbar < Components::Base
  def view_template
    header(
      class: [
        "supports-backdrop-blur:bg-background/80 sticky top-0 z-50 w-full border-b bg-background/80 backdrop-blur-2xl backdrop-saturate-200",
        ("hidden" if hotwire_native_app?)
      ]
    ) do
      div(class: "px-2 sm:px-4 sm:container flex h-14 items-center justify-between") do
        div(class: "flex items-center") do
          MobileMenu(class: "md:hidden")

          Aljam3Logo(class: "h-9 text-primary me-4 max-sm:ps-1")

          nav_link(root_path, "static", "home") { t(".home") }
          nav_link(categories_path, "categories") { t(".categories") }
          nav_link(authors_path, "authors") { t(".authors") }
          nav_link(books_path, "books") { t(".books") }
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

          LanguageDropdown(placement: "bottom-end") do
            Button(variant: :ghost, icon: true) do
              render [
                Bootstrap::GlobeAmericas,
                Bootstrap::GlobeAsiaAustralia,
                Bootstrap::GlobeCentralSouthAsia,
                Bootstrap::GlobeEuropeAfrica
              ].sample.new(class: "size-5")
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

  def active_link?(controller_name, action_name = nil)
    if action_name
      controller_name == self.controller_name && action_name == self.action_name
    else
      controller_name == self.controller_name
    end
  end

  def nav_link(path, controller_name, action_name = nil)
    Link(
      href: path,
      variant: :ghost,
      size: :lg,
              class: [
          "hidden md:inline-block relative me-1",
          ("after:absolute after:bottom-0 after:left-0 after:h-0.5 after:w-full after:bg-primary after:rounded-full" if active_link?(controller_name, action_name))
        ]
    ) { yield }
  end

  def theme_toggle
    ThemeToggle do
      SetLightMode { Button(variant: :ghost, icon: true) { Lucide::Sun(class: "size-5") } }
      SetDarkMode { Button(variant: :ghost, icon: true) { Remix::MoonFill(class: "size-4.5") } }
    end
  end
end
