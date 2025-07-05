# frozen_string_literal: true

class Components::MobileMenu < Components::Base
  def initialize(**attrs)
    super(**attrs)
  end

  def view_template(&)
    Sheet(**attrs) do
      SheetTrigger(class: "me-2") { Button(variant: :ghost, icon: true) { Lucide::Menu(class: "size-5") } }

      SheetContent(class: "w-[350px] max-sm:w-full", side:) do
        div(class: "flex flex-col h-full") do
          SheetHeader { Logo() }

          div(class: "flex-grow overflow-y-scroll") do
            SheetMiddle { Menu() }
          end
        end
      end
    end
  end
end
