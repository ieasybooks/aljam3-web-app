Rack::Attack.blocklist("CloudFlare WAF bypass") do |req|
  req.path != "/up" && Rails.env.production? && !req.cloudflare?
end

Rack::Attack.throttle("API Requests/IP", limit: 60, period: 1.minute) do |req|
  req.ip if req.path.include?("/api/")
end
