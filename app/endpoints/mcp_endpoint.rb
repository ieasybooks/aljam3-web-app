class McpEndpoint
  def self.call(env)
    status, headers, body = response_for(ActionDispatch::Request.new(env))
    [ status, headers.merge("cache-control" => "no-store"), body ]
  end

  def self.response_for(request)
    origin = request.get_header("HTTP_ORIGIN")
    return [ 403, {}, [] ] if origin && origin != request.base_url
    return [ 405, { "allow" => "POST" }, [] ] unless request.post?

    count = Rails.cache.increment("rate-limit:mcp:ip:#{request.remote_ip}", 1, expires_in: 1.minute)
    return [ 429, { "retry-after" => "60" }, [] ] if count && count > 300

    MCP::Server::Transports::StreamableHTTPTransport.new(
      Mcp::Server.build(url_base: request.base_url),
      stateless: true,
      enable_json_response: true,
      serve_subscriptions_listen: false,
      allowed_hosts: Rails.application.config.hosts.grep(String) + %w[aljam3.com www.aljam3.com]
    ).call(request.env)
  end

  private_class_method :response_for
end
