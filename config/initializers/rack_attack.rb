Rack::Attack.blocklist("CloudFlare WAF bypass") do |req|
  !req.cloudflare?
end
