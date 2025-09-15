# frozen_string_literal: true

class Components::Menu < Components::Base
  def initialize(controller_name: nil, action_name: nil)
    @controller_name = controller_name
    @action_name = action_name
  end

  def view_template
    div(class: "pb-4") do
      menu_link(path: root_path, text: t("navbar.home"), icon: Hero::Home.new(variant: :outline, class: "size-5")) unless hotwire_native_app?
      Separator(class: "my-2") unless hotwire_native_app?

      unless hotwire_native_app?
        menu_link(path: categories_path, text: t("navbar.categories"), icon: Lucide::LayoutGrid.new(variant: :outline, class: "size-5"))
        Separator(class: "my-2")
        menu_link(path: authors_path, text: t("navbar.authors"), icon: Bootstrap::Feather.new(class: "size-5"))
        Separator(class: "my-2")
        menu_link(path: books_path, text: t("navbar.books"), icon: Hero::BookOpen.new(variant: :outline, class: "size-5"))
        Separator(class: "my-2")
      end

      if hotwire_native_app? || (@controller_name == "pages" && @action_name == "show")
        if user_signed_in?
          Link(
            variant: :link,
            href: destroy_user_session_path,
            class: "flex items-center justify-start gap-x-2 text-xl text-muted-foreground",
            data: {
              controller: "bridge--sign-out",
              bridge__sign_out_path_value: api_v1_auth_path,
              action: [
                ("click->ruby-ui--sheet-content#close" if hotwire_native_app?),
                "bridge--sign-out#signOut"
              ],
              turbo_method: :delete
            }
          ) do
            Hero::ArrowLeftStartOnRectangle(variant: :outline, class: "size-5 ltr:transform ltr:-scale-x-100")

            plain t("navbar.sign_out")
          end
        else
          menu_link(
            path: new_user_session_path,
            text: t("navbar.sign_in"),
            icon: Hero::ArrowLeftOnRectangle.new(variant: :outline, class: "size-5 ltr:transform ltr:-scale-x-100"),
          )
        end

        Separator(class: "my-2")

        if hotwire_native_app?
          menu_link(
            path: new_contact_path,
            text: t("navbar.contact_us"),
            icon: Bootstrap::Mailbox.new(variant: :outline, class: "size-5 ltr:transform ltr:-scale-x-100"),
            close_sheet: false
          )
        else
          ContactDialog do
            Button(variant: :link, class: "flex items-center gap-x-2 text-muted-foreground text-xl") do
              Bootstrap::Mailbox(class: "size-5 ltr:transform ltr:-scale-x-100")

              plain t("navbar.contact_us")
            end
          end
        end

        Separator(class: "my-2")

        LanguageDropdown(placement: "bottom-start") do
          Button(variant: :link, class: "flex items-center gap-x-2 text-muted-foreground text-xl") do
            render [
              Bootstrap::GlobeAmericas,
              Bootstrap::GlobeAsiaAustralia,
              Bootstrap::GlobeCentralSouthAsia,
              Bootstrap::GlobeEuropeAfrica
            ].sample.new(class: "size-5")

            plain t("navbar.language")
          end
        end

        Separator(class: "my-2")

        theme_toggle
      end
    end
  end

  private

  def menu_link(path:, text:, icon:, close_sheet: true)
    Link(
      variant: :link,
      href: path,
      class: [
        "flex items-center justify-start gap-x-2 text-xl",
        (path == request.path ? "text-foreground font-medium" : "text-muted-foreground")
      ],
      data: { action: ("click->ruby-ui--sheet-content#close" if hotwire_native_app? && close_sheet) }
    ) do
      render icon

      plain text
    end
  end

  def theme_toggle
    ThemeToggle do
      SetLightMode do
        Button(
          variant: :link,
          class: "flex items-center gap-x-2 text-muted-foreground text-xl",
          data: { action: "click->bridge--theme#toggleDark" }
        ) do
          Remix::MoonFill(class: "size-5")

          plain t(".dark_mode")
        end
      end

      SetDarkMode do
        Button(
          variant: :link,
          class: "flex items-center gap-x-2 text-muted-foreground text-xl",
          data: { action: "click->bridge--theme#toggleLight" }
        ) do
          Lucide::Sun(class: "size-5")

          plain t(".light_mode")
        end
      end
    end
  end
end
