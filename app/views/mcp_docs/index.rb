class Views::McpDocs::Index < Views::Base
  def page_title = t("mcp_docs.title")
  def description = t("mcp_docs.description")

  def head
    -> do
      canonical = "#{Mcp::Documentation::ORIGIN}#{mcp_docs_path(locale: I18n.locale)}"
      link rel: "canonical", href: canonical
      I18n.available_locales.each do |locale|
        link rel: "alternate", hreflang: locale, href: "#{Mcp::Documentation::ORIGIN}#{mcp_docs_path(locale:)}"
      end
      meta property: "og:title", content: "#{t('aljam3')} | #{page_title}"
      meta property: "og:description", content: description
      meta property: "og:type", content: "website"
      meta property: "og:url", content: canonical
    end
  end

  def view_template
    main(class: "isolate mx-auto flex w-full max-w-6xl flex-col gap-14 px-4 py-10 antialiased sm:px-6 sm:py-16 lg:gap-20") do
      overview
      capabilities
      setup
      prompts
      reference
    end
  end

  private

  def overview
    section(class: "grid gap-8 lg:grid-cols-[3fr_2fr] lg:items-center", aria: { labelledby: "mcp-heading" }) do
      header(class: "flex min-w-0 flex-col items-start gap-5") do
        p(class: "text-base font-medium text-primary dark:text-foreground") { t("mcp_docs.eyebrow") }
        h1(id: "mcp-heading", class: "max-w-[24ch] text-4xl font-medium tracking-tight text-balance sm:text-5xl") { t("mcp_docs.heading") }
        p(class: "max-w-[48ch] text-lg/8 text-pretty text-foreground/80") { description }
        div(class: "text-base font-medium") do
          a(href: "#setup", class: "inline-flex min-h-12 items-center rounded-lg bg-primary px-4 py-3 text-primary-foreground hover:bg-primary/90 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring") { t("mcp_docs.get_started") }
        end
      end

      aside(class: "flex min-w-0 flex-col gap-5 rounded-xl border border-foreground/10 bg-muted p-5 sm:p-6") do
        h2(class: "text-xl font-medium text-balance") { t("mcp_docs.connection_title") }
        div(class: "flex min-w-0 flex-col items-start gap-3", data: clipboard_data) do
          p(class: "w-full overflow-x-auto rounded-lg bg-background p-4 font-mono text-base", dir: "ltr", tabindex: "0", aria: { label: t("mcp_docs.connection_url") }) do
            code(data: { clipboard_target: "source" }) { Mcp::Documentation::ENDPOINT }
          end
          copy_button(t("mcp_docs.copy_url"))
        end
        p(class: "text-base/7 text-pretty text-foreground/80") { t("mcp_docs.connection_note") }
        dl(class: "flex flex-wrap gap-x-8 gap-y-4 text-base sm:text-sm") do
          div(class: "flex flex-col gap-1") do
            dt(class: "font-medium") { t("mcp_docs.transport_label") }
            dd(class: "text-foreground/80", dir: "ltr") { "Streamable HTTP" }
          end
          div(class: "flex flex-col gap-1") do
            dt(class: "font-medium") { t("mcp_docs.authentication_label") }
            dd(class: "text-foreground/80") { t("mcp_docs.authentication_value") }
          end
        end
      end
    end
  end

  def capabilities
    section(class: "flex flex-col gap-6", aria: { labelledby: "capabilities-heading" }) do
      h2(id: "capabilities-heading", class: "text-2xl font-medium tracking-tight text-balance sm:text-3xl") { t("mcp_docs.capabilities_title") }
      dl(class: "grid gap-8 md:grid-cols-3") do
        t("mcp_docs.capabilities").each do |item|
          div(class: "flex flex-col gap-2 border-t border-foreground/10 pt-5") do
            dt(class: "text-lg font-medium") { item.fetch(:title) }
            dd(class: "text-base/7 text-pretty text-foreground/80") { item.fetch(:body) }
          end
        end
      end
    end
  end

  def setup
    section(id: "setup", class: "scroll-mt-24", aria: { labelledby: "setup-heading" }) do
      header(class: "flex flex-col gap-3 pb-6") do
        h2(id: "setup-heading", class: "text-2xl font-medium tracking-tight text-balance sm:text-3xl") { t("mcp_docs.setup_title") }
        p(class: "max-w-[65ch] text-base/7 text-pretty text-foreground/80") { t("mcp_docs.setup_intro") }
      end
      Mcp::Documentation::CLIENTS.each do |key, client|
        article(id: "setup-#{key}", class: "grid gap-8 border-t border-foreground/10 py-8 lg:grid-cols-[2fr_3fr]") do
          div(class: "flex min-w-0 flex-col items-start gap-3") do
            h3(class: "text-2xl font-medium tracking-tight text-balance", dir: "auto") { client.fetch(:name) }
            p(class: "text-base/7 text-pretty text-foreground/80") { t("mcp_docs.clients.#{key}.note") }
            p(class: "text-base font-medium") do
              a(href: client.fetch(:source), class: "rounded-sm text-primary underline decoration-primary/30 underline-offset-4 hover:decoration-current dark:text-foreground", target: "_blank", rel: "noopener noreferrer") { t("mcp_docs.official_docs") }
            end
          end
          ol(class: "min-w-0 list-decimal space-y-4 ps-6 text-base/8 text-foreground/80") do
            t("mcp_docs.clients.#{key}.steps", endpoint: Mcp::Documentation::ENDPOINT).each do |step|
              li(class: "ps-1 text-pretty wrap-anywhere") { step }
            end
          end
        end
      end
    end
  end

  def prompts
    section(class: "flex flex-col gap-6", aria: { labelledby: "prompts-heading" }) do
      header(class: "flex flex-col gap-3") do
        h2(id: "prompts-heading", class: "text-2xl font-medium tracking-tight text-balance sm:text-3xl") { t("mcp_docs.prompts_title") }
        p(class: "max-w-[65ch] text-base/7 text-pretty text-foreground/80") { t("mcp_docs.prompts_intro") }
      end
      div(class: "grid gap-8 md:grid-cols-2") do
        t("mcp_docs.prompts").each do |prompt|
          div(class: "flex flex-col items-start gap-5 rounded-xl border border-foreground/10 p-5 sm:p-6", data: clipboard_data) do
            p(class: "grow text-base/8 text-pretty", data: { clipboard_target: "source" }) { prompt }
            copy_button(t("mcp_docs.copy_prompt"))
          end
        end
      end
      p(class: "max-w-[80ch] text-base/7 text-pretty text-foreground/80") { t("mcp_docs.source_note") }
    end
  end

  def reference
    details(class: "rounded-xl border border-foreground/10 p-5 sm:p-6") do
      summary(class: "cursor-pointer rounded-sm text-lg font-medium focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring") { t("mcp_docs.reference_title") }
      div(class: "flex flex-col gap-8 pt-6") do
        dl(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
          # i18n-tasks-use t("mcp_docs.tools.#{name}")
          t("mcp_docs.tools").each do |name, body|
            div(class: "flex min-w-0 flex-col gap-2") do
              dt(class: "font-mono text-base font-medium", dir: "ltr") { name }
              dd(class: "text-base/7 text-pretty text-foreground/80") { body }
            end
          end
        end
        div(class: "flex flex-col gap-3 border-t border-foreground/10 pt-6") do
          h3(class: "text-lg font-medium text-balance") { t("mcp_docs.limits_title") }
          ul(class: "list-disc space-y-2 ps-5 text-base/7 text-foreground/80") do
            t("mcp_docs.limits").each { |limit| li(class: "text-pretty") { limit } }
          end
        end
      end
    end
  end

  def clipboard_data
    { controller: "clipboard", clipboard_success_content_value: t("mcp_docs.copied") }
  end

  def copy_button(label)
    button(type: "button", class: "relative min-h-12 rounded-lg px-3 py-2 text-base font-medium text-primary hover:bg-primary/10 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-ring sm:text-sm dark:text-foreground", data: { action: "clipboard#copy", clipboard_target: "button" }, aria: { live: "polite" }) { label }
  end
end
