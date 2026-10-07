# frozen_string_literal: true

class Components::DesktopDownloadDialog < Components::Base
  def view_template
    dialog(
      id: "desktop-download",
      aria: { labelledby: "desktop-download-title", describedby: "desktop-download-description" },
      class: "m-auto w-[calc(100%-2rem)] max-w-lg max-h-[calc(100dvh-2rem)] overflow-y-auto rounded-lg border border-border bg-background p-5 text-foreground shadow-lg dark:shadow-none backdrop:bg-background/80 backdrop:backdrop-blur-sm",
      data: {
        desktop_download_target: "dialog",
        action: "click->desktop-download#dismissBackdrop close->desktop-download#restoreScroll"
      }
    ) do
      div(class: "flex flex-col gap-5") do
        header(class: "flex flex-col gap-2 pe-8") do
          h2(id: "desktop-download-title", class: "text-xl font-semibold text-balance") { t("desktop_download.title") }
          p(id: "desktop-download-description", class: "text-base sm:text-sm text-muted-foreground text-pretty") { t("desktop_download.description") }
          p(class: "text-base sm:text-sm text-muted-foreground") { t("desktop_download.free_latest") }
        end

        div(class: "grid gap-4 sm:grid-cols-2") do
          platform(
            name: "Windows",
            requirements: t("desktop_download.windows_requirements"),
            label: t("desktop_download.download_windows"),
            target: "windows"
          )
          platform(
            name: "macOS",
            requirements: t("desktop_download.macos_requirements"),
            label: t("desktop_download.download_macos"),
            target: "macos"
          )
        end

        details(class: "border-t border-border pt-4") do
          summary(class: "cursor-pointer rounded-sm focus-visible:outline-2 focus-visible:outline-ring text-base sm:text-sm") { t("desktop_download.install_help") }
          div(class: "mt-3 flex flex-col gap-3 text-base sm:text-sm text-muted-foreground text-pretty") do
            p { t("desktop_download.windows_help") }
            p { t("desktop_download.macos_help") }
          end
        end

        div(class: "flex flex-wrap items-center justify-between gap-2") do
          Link(href: DesktopRelease::RELEASES_URL, target: "_blank", rel: "noopener", class: "h-12 sm:h-9 px-0 dark:text-foreground") { t("desktop_download.release_notes") }
          Button(variant: :outline, class: "h-12 sm:h-9", data: { action: "click->desktop-download#close" }) { t("close") }
        end
      end

      Button(
        variant: :ghost,
        icon: true,
        size: :xl,
        class: "absolute end-1 top-1 sm:size-9",
        aria: { label: t("close") },
        data: { action: "click->desktop-download#close" }
      ) { Lucide::X(class: "size-6 shrink-0") }
    end
  end

  private

  def platform(name:, requirements:, label:, target:)
    section(class: "flex flex-col gap-3 rounded-md border border-border p-4") do
      h3(class: "font-semibold") { bdi { name } }
      p(class: "grow text-base sm:text-sm text-muted-foreground text-pretty") { bdi { requirements } }
      Link(
        href: desktop_download_path(platform: target),
        variant: :outline,
        class: "h-12 sm:h-9 w-full px-3 dark:shadow-none",
        data: { turbo: false }
      ) { label }
    end
  end
end
