require "rails_helper"

# rubocop:disable RSpec/ExampleLength -- Keep complete protocol scenarios together.
RSpec.describe "MCP transport", :aggregate_failures do
  include ActiveSupport::Testing::TimeHelpers

  before do
    host! "aljam3.com"
    https!
  end

  %w[2025-03-26 2025-06-18 2025-11-25].each do |version|
    it "initializes #{version} without authentication or a session" do
      mcp_post("initialize", params: { protocolVersion: version, capabilities: {}, clientInfo: { name: "Test", version: "1" } })
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("result", "protocolVersion")).to eq(version)
      expect(response.parsed_body.dig("result", "serverInfo", "name")).to eq("aljam3")
      expect(response.headers).not_to include("Mcp-Session-Id", "WWW-Authenticate")
    end
  end

  it "discovers only the seven bounded, read-only tools" do
    mcp_post
    tools = response.parsed_body.dig("result", "tools")
    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("application/json")
    expect(response.headers["Cache-Control"]).to eq("no-store")
    expect(tools.pluck("name")).to eq(%w[search list_books get_book get_page list_authors list_categories list_libraries])
    tools.each do |tool|
      expect(tool.fetch("annotations")).to include("readOnlyHint" => true, "destructiveHint" => false, "idempotentHint" => true)
      expect(tool.dig("inputSchema", "additionalProperties")).to be(false)
      expect(tool.fetch("description")).to include("Aljam3 url")
    end
  end

  it "accepts initialization notifications with an empty body" do
    mcp_post("notifications/initialized", id: nil)
    expect(response).to have_http_status(:accepted)
    expect(response.body).to be_empty
  end

  it "allows same-origin browsers and native clients on loopback" do
    mcp_post(headers: { "Origin" => "https://aljam3.com" })
    expect(response).to have_http_status(:ok)
    host! "localhost"
    mcp_post
    expect(response).to have_http_status(:ok)
  end

  it "allows a deployment host explicitly configured in Rails" do
    Rails.application.config.hosts << "mcp.aljam3.test"
    host! "mcp.aljam3.test"
    mcp_post
    expect(response).to have_http_status(:ok)
  ensure
    Rails.application.config.hosts.delete("mcp.aljam3.test")
  end

  [ "https://attacker.example", "null", "http://aljam3.com" ].each do |origin|
    it "rejects origin #{origin}" do
      mcp_post(headers: { "Origin" => origin })
      expect(response).to have_http_status(:forbidden)
      expect(response.headers["Cache-Control"]).to eq("no-store")
    end
  end

  it "rejects an untrusted host" do
    host! "attacker.example"
    mcp_post
    expect(response).to have_http_status(:forbidden)
  end

  %i[get head delete put patch options].each do |method|
    it "rejects #{method} and advertises POST" do
      public_send(method, "/mcp", headers: mcp_headers)
      expect(response).to have_http_status(:method_not_allowed)
      expect(response.headers["Allow"]).to eq("POST")
    end
  end

  it "rejects malformed JSON before Rails parameter parsing" do
    post "/mcp", params: "{", headers: mcp_headers
    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body.dig("error", "code")).to eq(-32700)
  end

  it "rejects oversized bodies before constructing a tool result" do
    post "/mcp", params: "x" * (4.megabytes + 1), headers: mcp_headers
    expect(response).to have_http_status(:content_too_large)
  end

  it "requires JSON and an appropriate Accept header" do
    mcp_post(headers: { "Content-Type" => "text/plain" })
    expect(response).to have_http_status(:unsupported_media_type)
    mcp_post(headers: { "Accept" => "text/html" })
    expect(response).to have_http_status(:not_acceptable)
  end

  it "throttles by IP, including discovery, and recovers after one minute" do
    cache = ActiveSupport::Cache::MemoryStore.new
    allow(Rails).to receive(:cache).and_return(cache)
    cache.write("rate-limit:mcp:ip:198.51.100.1", 299, expires_in: 1.minute)
    mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
    expect(response).to have_http_status(:ok)
    mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
    expect(response).to have_http_status(:too_many_requests)
    expect(response.headers).to include("Retry-After" => "60", "Cache-Control" => "no-store")
    mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.2" })
    expect(response).to have_http_status(:ok)
    travel 61.seconds do
      mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
      expect(response).to have_http_status(:ok)
    end
  end

  [
    [ "search", {} ], [ "search", { q: " " } ], [ "search", { q: "x" * 501 } ],
    [ "search", { q: "فقه", book_id: "1 OR hidden = true" } ],
    [ "search", { q: "فقه", author_id: [ 1 ] } ],
    [ "list_books", { per_page: 21 } ], [ "list_books", { per_page: 0 } ],
    [ "list_books", { page: 101 } ], [ "list_books", { locale: "fr" } ],
    [ "get_book", { id: -1 } ], [ "get_book", { id: 1, expand: "all" } ],
    [ "get_page", { file_id: 1 } ], [ "get_page", { file_id: 1, page_number: 1, offset: -1 } ],
    [ "get_page", { file_id: 1, page_number: 1, max_chars: 12_001 } ]
  ].each do |name, arguments|
    it "rejects invalid #{name} arguments #{arguments.keys.join(',')} #{arguments.values.map { |value| value.to_s.first(10) }.join(',')}" do
      mcp_post("tools/call", params: { name:, arguments: })
      expect(response.parsed_body.fetch("result")).to include("isError" => true)
      expect(response.parsed_body.fetch("result")).not_to have_key("structuredContent")
    end
  end

  it "returns a protocol error for an unknown tool" do
    mcp_post("tools/call", params: { name: "delete_book", arguments: { id: 1 } })
    expect(response.parsed_body.dig("error", "code")).to eq(-32602)
  end
end
# rubocop:enable RSpec/ExampleLength
