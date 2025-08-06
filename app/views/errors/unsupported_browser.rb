class Views::Errors::UnsupportedBrowser < Views::Base
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
                  d: "M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                )
              end
            end
          end

          div(class: "space-y-2") do
            h1(class: "scroll-m-20 text-4xl font-bold tracking-tight text-primary") { "406" }
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
