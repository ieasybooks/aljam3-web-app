# frozen_string_literal: true

class Components::MobileMenu < Components::Base
  def initialize(controller_name: nil, action_name: nil, **attrs)
    @controller_name = controller_name
    @action_name = action_name

    super(**attrs)
  end

  def view_template(&)
    Sheet(id: "mobile-menu", **attrs) do
      SheetTrigger(class: "me-2") { Button(variant: :ghost, icon: true) { Lucide::Menu(class: "size-5") } }

      SheetContent(
        id: "mobile-menu-content",
        class: [
          "w-[350px] max-sm:w-full max-sm:border-none",
          ("pt-[calc(env(safe-area-inset-top)+24px)]" if ios_native_app?)
        ],
        side:
      ) do
        div(class: "flex flex-col h-full") do
          SheetHeader(class: "flex items-center justify-center py-8") { Aljam3Logo(class: "h-30 text-primary") }

          div(class: "flex-grow overflow-y-scroll") do
            SheetMiddle { Menu(controller_name: @controller_name, action_name: @action_name) }
          end
        end
      end
    end
  end
end
