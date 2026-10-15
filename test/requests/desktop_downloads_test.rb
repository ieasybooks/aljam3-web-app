require "test_helper"

class DesktopDownloadsTest < ApplicationTest
  setup do
    @version = "0.0.3"
    @release = {
      tag_name: "v#{@version}",
      assets: %w[windows-x64-setup.exe macos-arm64.dmg].map do |suffix|
        name = "Aljam3-#{@version}-#{suffix}"
        { name:, browser_download_url: "https://github.com/ieasybooks/aljam3-desktop/releases/download/v#{@version}/#{name}" }
      end
    }
    Rails.stubs(:cache).returns(ActiveSupport::Cache::MemoryStore.new)
    stub_release(@release)
  end

  test "downloads the Windows installer from every supported locale" do
    %w[ar en ur].each do |locale|
      get "/#{locale}/desktop/windows"
      assert_redirected_to @release[:assets].first[:browser_download_url]
    end
  end

  test "downloads the Apple silicon disk image" do
    get "/ar/desktop/macos"

    assert_redirected_to @release[:assets].last[:browser_download_url]
  end

  test "caches the release across platforms and locales" do
    request = stub_release(@release)
    get "/ar/desktop/windows"
    get "/en/desktop/macos"

    assert_requested request, times: 1
  end

  test "falls back when an asset is missing or untrusted" do
    @release[:assets].shift
    stub_release(@release)
    get "/desktop/windows"
    assert_redirected_to DesktopRelease::RELEASES_URL

    @release[:assets] = [ { name: "installer", browser_download_url: "https://example.com/untrusted.exe" } ]
    stub_release(@release)
    get "/desktop/windows"
    assert_redirected_to DesktopRelease::RELEASES_URL
  end

  test "falls back for malformed, invalid, or unavailable release responses" do
    [
      nil,
      "not json",
      { tag_name: "v../other", assets: [] }.to_json
    ].each do |body|
      stub_request(:get, DesktopRelease::API_URL).to_return(body: body.to_s)
      get "/desktop/windows"
      assert_redirected_to DesktopRelease::RELEASES_URL
    end

    [ 403, 404, 503 ].each do |status|
      stub_request(:get, DesktopRelease::API_URL).to_return(status:)
      get "/desktop/windows"
      assert_redirected_to DesktopRelease::RELEASES_URL
    end
  end

  private

  def stub_release(release)
    stub_request(:get, DesktopRelease::API_URL).to_return(body: release.to_json)
  end
end
