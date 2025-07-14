# frozen_string_literal: true

class Components::Banner < Components::Base
  def view_template
    div(class: "flex items-center justify-center w-full h-10 text-white bg-primary", data: { controller: "banner" }) do
      a(class: "hover:underline text-center truncate px-2", target: "_blank", data: { banner_target: "link" })
    end
  end
end
