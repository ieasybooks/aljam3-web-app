# frozen_string_literal: true

class Components::DesktopDownloadButton < Components::Base
  def view_template(&)
    Button(
      variant: :outline,
      **attrs,
      aria: { haspopup: "dialog", controls: "desktop-download" },
      data: { action: "click->desktop-download#open" },
      &
    )
  end
end
