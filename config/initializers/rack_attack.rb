Rack::Attack.blocklist("CloudFlare WAF bypass") do |req|
  req.path != "/up" && Rails.env.production? && !req.cloudflare?
end
