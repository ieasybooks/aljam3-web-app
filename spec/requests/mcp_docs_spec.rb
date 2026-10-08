require "rails_helper"

# rubocop:disable RSpec/ExampleLength -- Exercise the guide and protocol together through their shared URL.
RSpec.describe "MCP documentation", :aggregate_failures do
  before do
    host! "aljam3.com"
    https!
  end

  %w[ar ur en].each do |locale|
    it "serves the public #{locale} guide with localized metadata and navigation" do
      cookies[:locale] = locale == "ar" ? "en" : "ar"
      get "/#{locale}/mcp", headers: { "Accept" => "text/html" }

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/html")
      expect(response.headers["Content-Language"]).to eq(locale)
      doc = response.parsed_body
      expect(doc.at_css("html").attributes.transform_values(&:value)).to include("lang" => locale, "dir" => locale == "en" ? "ltr" : "rtl")
      expect(doc.at_css("h1").text).to eq(I18n.t("mcp_docs.heading", locale:))
      expect(doc.at_css("head title").text).to include(I18n.t("mcp_docs.title", locale:))
      expect(doc.at_css("head meta[name='description']")["content"]).to eq(I18n.t("mcp_docs.description", locale:))
      expect(doc.at_css("head link[rel='canonical']")["href"]).to eq("https://aljam3.com/#{locale}/mcp")
      expect(doc.at_css("head meta[property='og:url']")["content"]).to eq("https://aljam3.com/#{locale}/mcp")
      %w[ar ur en].each do |alternate|
        expect(doc.at_css("head link[rel='alternate'][hreflang='#{alternate}']")["href"]).to eq("https://aljam3.com/#{alternate}/mcp")
      end
      expect(doc.css("a[href='/#{locale}/mcp']").count { |link| link.text == I18n.t("mcp_docs.nav_label", locale:) }).to eq(2)
      expect(doc.css("article[id^='setup-']").size).to eq(2)
      expect(doc.css("[data-clipboard-target='source']").size).to eq(3)
      expect(response.body).not_to include("translation_missing", "Translation missing", "%{endpoint}")
    end
  end

  [ nil, "text/html", "*/*", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" ].each do |accept|
    it "serves the guide for browser Accept #{accept.inspect} using the locale cookie" do
      cookies[:locale] = "en"
      get "/mcp", headers: { "Accept" => accept }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css("html")["lang"]).to eq("en")
    end
  end

  it "uses the browser language when the visitor has no locale preference" do
    get "/mcp", headers: { "Accept" => "text/html", "Accept-Language" => "ur,en;q=0.8" }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("html")["lang"]).to eq("ur")
  end

  it "supports HTML HEAD requests without a response body" do
    head "/mcp", headers: { "Accept" => "text/html" }

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/html")
    expect(response.body).to be_empty
  end

  it "keeps the public connection link and canonical URL on localhost" do
    host! "localhost"
    get "/en/mcp"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("aside code").text).to eq("https://aljam3.com/mcp")
    expect(response.parsed_body.at_css("head link[rel='canonical']")["href"]).to eq("https://aljam3.com/en/mcp")
    expect(response.parsed_body.css("#setup ol").text.scan("https://aljam3.com/mcp").size).to eq(2)
  end

  [ "application/json, text/event-stream", "text/event-stream", "text/event-stream, */*;q=0.5", "application/json, text/html;q=0.5" ].each do |accept|
    it "preserves protocol GET rejection for Accept #{accept.inspect}" do
      get "/mcp", headers: { "Accept" => accept }

      expect(response).to have_http_status(:method_not_allowed)
      expect(response.headers["Allow"]).to eq("POST")
    end
  end

  it "documents the exposed tools and keeps POST discovery available after browsing the guide" do
    get "/en/mcp"
    documented_tools = response.parsed_body.css("details dt").map(&:text)

    mcp_post

    expect(response).to have_http_status(:ok)
    tools = response.parsed_body.dig("result", "tools")
    expect(tools.size).to eq(7)
    expect(documented_tools).to match_array(tools.pluck("name"))
  end
end
# rubocop:enable RSpec/ExampleLength
