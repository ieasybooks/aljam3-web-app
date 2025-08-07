# frozen_string_literal: true

class Components::TxtContentSkeleton < Components::Base
  def view_template
    div(class: "space-y-2 flex flex-col items-end rtl:items-start") do
      Skeleton(class: "h-4 w-[250px]")
      Skeleton(class: "h-4 w-[200px]")
      Skeleton(class: "h-4 w-[300px]")
      Skeleton(class: "h-4 w-[100px]")
      Skeleton(class: "h-4 w-[150px]")
    end
  end
end
