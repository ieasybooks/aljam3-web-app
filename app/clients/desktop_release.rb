# frozen_string_literal: true

require "net/http"

class DesktopRelease
  RELEASES_URL = "https://github.com/ieasybooks/aljam3-desktop/releases/latest"
  API_URL = "https://api.github.com/repos/ieasybooks/aljam3-desktop/releases/latest"
  PACKAGES = { "windows" => "windows-x64-setup.exe", "macos" => "macos-arm64.dmg" }.freeze

  def self.download_url(platform)
    downloads = Rails.cache.fetch("desktop-release-downloads", expires_in: 1.hour, skip_nil: true) { fetch_downloads }
    downloads&.fetch(platform, nil) || RELEASES_URL
  end

  def self.fetch_downloads
    uri = URI(API_URL)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 2, read_timeout: 3, max_retries: 0) do |http|
      http.get(uri.request_uri, { "Accept" => "application/vnd.github+json", "User-Agent" => "Aljam3-Web" })
    end
    return unless response.is_a?(Net::HTTPSuccess)

    release = JSON.parse(response.body)
    return unless release.is_a?(Hash) && /\Av\d+\.\d+\.\d+\z/.match?(release["tag_name"].to_s) && release["assets"].is_a?(Array)

    version = release.fetch("tag_name").delete_prefix("v")
    PACKAGES.to_h do |platform, suffix|
      name = "Aljam3-#{version}-#{suffix}"
      url = "https://github.com/ieasybooks/aljam3-desktop/releases/download/v#{version}/#{name}"
      available = release.fetch("assets").any? { |asset| asset.is_a?(Hash) && asset["name"] == name && asset["browser_download_url"] == url }
      [ platform, (url if available) ]
    end
  rescue JSON::ParserError, Timeout::Error, SocketError, SystemCallError, IOError, Net::HTTPBadResponse, Net::ProtocolError, OpenSSL::SSL::SSLError
    nil
  end
  private_class_method :fetch_downloads
end
