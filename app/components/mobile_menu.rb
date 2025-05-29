# frozen_string_literal: true

class Components::MobileMenu < Components::Base
  def view_template
    Sheet(class: "md:hidden") do
      SheetTrigger(class: "me-2") { Button(variant: :ghost, icon: true) { Lucide::Menu(class: "size-5") } }

      SheetContent(class: "w-[300px]", side: sheet_side) do
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
