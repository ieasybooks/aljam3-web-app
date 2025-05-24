Rack::Attack.blocklist("CloudFlare WAF bypass") do |req|
  Rails.env.production? && !req.cloudflare?
end
