module McpRequests
  def mcp_headers
    { "Content-Type" => "application/json", "Accept" => "application/json, text/event-stream" }
  end

  def mcp_post(method = "tools/list", params: {}, id: 1, headers: {})
    body = { jsonrpc: "2.0", method:, params: }
    body[:id] = id unless id.nil?
    post "/mcp", params: body.to_json, headers: mcp_headers.merge(headers)
  end

  def mcp_call(name, arguments = {})
    mcp_post("tools/call", params: { name:, arguments: })
    response.parsed_body.fetch("result")
  end

  def mcp_data(name, arguments = {})
    mcp_call(name, arguments).fetch("structuredContent")
  end
end

RSpec.configure do |config|
  config.include McpRequests, type: :request
end
