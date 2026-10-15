require "test_helper"

class McpEndpointTest < ApplicationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    host! "aljam3.com"
    https!
  end

  test "initializes every supported protocol version" do
    %w[2025-03-26 2025-06-18 2025-11-25].each do |version|
      mcp_post("initialize", params: { protocolVersion: version, capabilities: {}, clientInfo: { name: "Test", version: "1" } })

      assert_response :ok
      assert_equal version, response.parsed_body.dig("result", "protocolVersion")
      assert_equal "aljam3", response.parsed_body.dig("result", "serverInfo", "name")
      refute response.headers.key?("Mcp-Session-Id")
      refute response.headers.key?("WWW-Authenticate")
    end
  end

  test "discovers bounded read-only tools" do
    mcp_post
    tools = response.parsed_body.dig("result", "tools")

    assert_response :ok
    assert_equal "application/json", response.media_type
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal %w[search list_books get_book get_page list_authors list_categories list_libraries], tools.pluck("name")
    tools.each do |tool|
      assert_equal true, tool.dig("annotations", "readOnlyHint")
      assert_equal false, tool.dig("annotations", "destructiveHint")
      assert_equal false, tool.dig("inputSchema", "additionalProperties")
    end
  end

  test "accepts and rejects query schema values" do
    %w[search list_books list_authors list_categories].each do |name|
      mcp_post
      schema_data = response.parsed_body.dig("result", "tools").find { |tool| tool["name"] == name }.fetch("inputSchema").fetch("properties").fetch("q")
      schema = JSONSchemer.schema(schema_data)
      full_pattern = Regexp.new("\\A(?:#{schema_data.fetch('pattern')})\\z")

      [ "a", "ف", "logic", "المنطق", "علم المنطق", "a" * 500 ].each do |query|
        assert schema.valid?(query), "#{name} should accept #{query.inspect}"
        assert_match full_pattern, query
      end
      [ "", " ", "\t\r\n", "a" * 501 ].each do |query|
        refute schema.valid?(query), "#{name} should reject #{query.inspect}"
        assert mcp_call(name, q: query).fetch("isError")
      end
    end
  end

  test "accepts initialization notifications without a response body" do
    mcp_post("notifications/initialized", id: nil)

    assert_response :accepted
    assert_empty response.body
  end

  test "allows trusted origins and configured hosts" do
    mcp_post(headers: { "Origin" => "https://aljam3.com" })
    assert_response :ok

    host! "localhost"
    mcp_post
    assert_response :ok

    Rails.application.config.hosts << "mcp.aljam3.test"
    host! "mcp.aljam3.test"
    mcp_post
    assert_response :ok
  ensure
    Rails.application.config.hosts.delete("mcp.aljam3.test")
  end

  test "rejects untrusted origins and hosts" do
    [ "https://attacker.example", "null", "http://aljam3.com" ].each do |origin|
      mcp_post(headers: { "Origin" => origin })
      assert_response :forbidden
      assert_equal "no-store", response.headers["Cache-Control"]
    end

    host! "attacker.example"
    mcp_post
    assert_response :forbidden
  end

  test "rejects non-POST requests" do
    %i[get head delete put patch options].each do |method|
      public_send(method, "/mcp", headers: mcp_headers)
      assert_response :method_not_allowed
      assert_equal "POST", response.headers["Allow"]
    end
  end

  test "rejects malformed and oversized requests" do
    post "/mcp", params: "{", headers: mcp_headers
    assert_response :bad_request
    assert_equal(-32700, response.parsed_body.dig("error", "code"))

    post "/mcp", params: "x" * (4.megabytes + 1), headers: mcp_headers
    assert_response :content_too_large
  end

  test "requires JSON and an MCP Accept header" do
    mcp_post(headers: { "Content-Type" => "text/plain" })
    assert_response :unsupported_media_type

    mcp_post(headers: { "Accept" => "text/html" })
    assert_response :not_acceptable
  end

  test "throttles requests by IP and recovers after one minute" do
    cache = ActiveSupport::Cache::MemoryStore.new
    Rails.stubs(:cache).returns(cache)
    cache.write("rate-limit:mcp:ip:198.51.100.1", 299, expires_in: 1.minute)

    mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
    assert_response :ok
    mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
    assert_response :too_many_requests
    assert_equal "60", response.headers["Retry-After"]

    travel 61.seconds do
      mcp_post(headers: { "REMOTE_ADDR" => "198.51.100.1" })
      assert_response :ok
    end
  end

  test "rejects invalid tool arguments" do
    invalid = [
      [ "search", {} ], [ "search", { q: " " } ], [ "search", { q: "x" * 501 } ],
      [ "search", { q: "فقه", book_id: "1 OR hidden = true" } ], [ "list_books", { per_page: 21 } ],
      [ "list_books", { page: 101 } ], [ "list_books", { locale: "fr" } ], [ "get_book", { id: -1 } ],
      [ "get_page", { file_id: 1 } ], [ "get_page", { file_id: 1, page_number: 1, offset: -1 } ]
    ]

    invalid.each do |name, arguments|
      mcp_post("tools/call", params: { name:, arguments: })
      result = response.parsed_body.fetch("result")
      assert_equal true, result.fetch("isError")
      refute result.key?("structuredContent")
    end
  end

  test "returns a protocol error for an unknown tool" do
    mcp_post("tools/call", params: { name: "delete_book", arguments: { id: 1 } })

    assert_equal(-32602, response.parsed_body.dig("error", "code"))
  end
end
