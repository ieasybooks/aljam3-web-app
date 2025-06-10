# frozen_string_literal: true

class Components::Menu < Components::Base
  def view_template
    div(class: "pb-4") do
      menu_link(text: t("navbar.home"), path: root_path)
    end
  end

  private

  def menu_link(text:, path:)
    a(
      href: path,
      class: [
        "group flex w-full items-center rounded-md border border-transparent px-2 py-1 hover:underline",
        (path == request.path ? "text-foreground font-medium" : "text-muted-foreground")
      ]
    ) { text }
  end
end
