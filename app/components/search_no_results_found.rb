# frozen_string_literal: true

class Components::SearchNoResultsFound < Components::Base
  def view_template
    div(class: "flex flex-col items-center gap-y-5 mt-10 px-4") do
      img(src: "/no_results_found.png", class: "mx-auto w-100")

      Text(size: "7", class: "text-center") { t(".no_results_found") }
    end
  end
end
