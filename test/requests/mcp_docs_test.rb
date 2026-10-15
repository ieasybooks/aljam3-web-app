require "test_helper"

class McpDocsTest < ApplicationTest
  setup do
    host! "aljam3.com"
    https!
  end

  test "serves each localized guide with metadata and navigation" do
    %w[ar ur en].each do |locale|
      cookies[:locale] = locale == "ar" ? "en" : "ar"
      get "/#{locale}/mcp", headers: { "Accept" => "text/html" }

      assert_response :ok
      assert_equal "text/html", response.media_type
      assert_equal locale, response.headers["Content-Language"]
      document = response.parsed_body
      assert_equal({ "lang" => locale, "dir" => locale == "en" ? "ltr" : "rtl" }, document.at_css("html").attributes.transform_values(&:value).slice("lang", "dir"))
      assert_equal I18n.t("mcp_docs.heading", locale:), document.at_css("h1").text
      assert_includes document.at_css("head title").text, I18n.t("mcp_docs.title", locale:)
      assert_equal I18n.t("mcp_docs.description", locale:), document.at_css("head meta[name='description']")["content"]
      assert_equal "https://aljam3.com/#{locale}/mcp", document.at_css("head link[rel='canonical']")["href"]
      assert_equal 3, document.css("[data-clipboard-target='source']").size
      refute_includes response.body, "translation_missing"
    end
  end

  test "uses the locale cookie for the browser route" do
    [ nil, "text/html", "*/*" ].each do |accept|
      cookies[:locale] = "en"
      get "/mcp", headers: { "Accept" => accept }

      assert_response :ok
      assert_equal "en", response.parsed_body.at_css("html")["lang"]
    end
  end

  test "uses the browser language without a locale cookie" do
    get "/mcp", headers: { "Accept" => "text/html", "Accept-Language" => "ur,en;q=0.8" }

    assert_response :ok
    assert_equal "ur", response.parsed_body.at_css("html")["lang"]
  end

  test "supports HTML HEAD requests without a response body" do
    head "/mcp", headers: { "Accept" => "text/html" }

    assert_response :ok
    assert_equal "text/html", response.media_type
    assert_empty response.body
  end

  test "uses the public connection URL on localhost" do
    host! "localhost"
    get "/en/mcp"

    assert_response :ok
    assert_equal "https://aljam3.com/mcp", response.parsed_body.at_css("aside code").text
    assert_equal "https://aljam3.com/en/mcp", response.parsed_body.at_css("head link[rel='canonical']")["href"]
  end

  test "rejects protocol Accept headers for GET" do
    [ "application/json, text/event-stream", "text/event-stream", "text/event-stream, */*;q=0.5" ].each do |accept|
      get "/mcp", headers: { "Accept" => accept }

      assert_response :method_not_allowed
      assert_equal "POST", response.headers["Allow"]
    end
  end

  test "documents the same tools exposed by protocol discovery" do
    get "/en/mcp"
    documented_tools = response.parsed_body.css("details dt").map(&:text)

    mcp_post

    assert_response :ok
    tools = response.parsed_body.dig("result", "tools")
    assert_equal 7, tools.size
    assert_equal tools.pluck("name").sort, documented_tools.sort
  end
end
