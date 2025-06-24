# frozen_string_literal: true

module RubyUI
  class Alert < Base
    def initialize(variant: nil, dismissible: false, **attrs)
      @variant = variant
      @dismissible = dismissible

      super(**attrs) # must be called after variant is set
    end

    def view_template(&)
      div(**attrs) do
        if @dismissible
          div(
            class: "absolute top-4 end-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-hidden focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none data-[state=open]:bg-accent data-[state=open]:text-muted-foreground cursor-pointer",
            data: { action: "click->ruby-ui--dismiss-alert#dismiss" }
          ) do
            PhlexIcons::Lucide::X(class: "size-4")
          end
        end

        yield
      end
    end

    private

    def colors
      case @variant
      when nil
        "ring-border bg-muted/20 text-foreground [&>svg]:opacity-80"
      when :warning
        "ring-warning/20 bg-warning/5 text-warning [&>svg]:text-warning/80"
      when :success
        "ring-success/20 bg-success/5 text-success [&>svg]:text-success/80"
      when :destructive
        "ring-destructive/20 bg-destructive/5 text-destructive [&>svg]:text-destructive/80"
      end
    end

    def default_attrs
      base_classes = "backdrop-blur relative w-full ring-1 ring-inset rounded-lg px-4 py-4 text-sm [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:start-4 [&>svg]:top-4 [&>svg~*]:ps-8"

      attrs = {
        class: [ base_classes, colors ],
        data: { controller: "ruby-ui--dismiss-alert" }
      }

      attrs.delete(:data) unless @dismissible

      attrs
    end
  end
end
