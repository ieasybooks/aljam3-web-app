class Views::Errors::UnprocessableContent < Views::Base
  def title = t(".title")
  def no_navbar = true

  def view_template
    div(class: "min-h-screen bg-background flex items-center justify-center p-4") do
      div(class: "w-full max-w-md") do
        div(class: "rounded-xl border bg-card shadow-lg p-8 text-center space-y-6") do
          div(class: "flex justify-center") do
            div(class: "rounded-full bg-warning/10 p-6") do
              svg(
                class: "w-16 h-16 text-warning",
                fill: "none",
                stroke: "currentColor",
                viewbox: "0 0 24 24"
              ) do |s|
                s.path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                )
              end
            end
          end

          div(class: "space-y-2") do
            h1(class: "scroll-m-20 text-4xl font-bold tracking-tight text-primary") { "422" }
            h2(class: "scroll-m-20 text-xl font-semibold tracking-tight text-primary") { title }
          end

          div(class: "space-y-4") do
            p(class: "text-base text-muted-foreground leading-7") { t(".description") }
            p(class: "text-sm text-muted-foreground") { t(".contact_us") }
          end
        end

        div(class: "text-center mt-6") do
          p(class: "text-xs text-muted-foreground") { t(".error_code") }
        end
      end
    end
  end
end
