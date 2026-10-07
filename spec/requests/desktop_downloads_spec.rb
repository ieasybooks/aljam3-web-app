require "rails_helper"

RSpec.describe "Desktop downloads" do
  let(:version) { "0.0.3" }
  let(:release) do
    {
      tag_name: "v#{version}",
      assets: %w[windows-x64-setup.exe macos-arm64.dmg].map do |suffix|
        name = "Aljam3-#{version}-#{suffix}"
        { name: name, browser_download_url: "https://github.com/ieasybooks/aljam3-desktop/releases/download/v#{version}/#{name}" }
      end
    }
  end
  let(:api_request) { stub_request(:get, DesktopRelease::API_URL).to_return(body: release.to_json) }

  before do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    api_request
  end

  it "downloads the Windows installer" do
    get "/ar/desktop/windows"

    expect(response).to redirect_to(release[:assets].first[:browser_download_url])
  end

  it "downloads the Apple silicon disk image" do
    get "/ar/desktop/macos"

    expect(response).to redirect_to(release[:assets].last[:browser_download_url])
  end

  %w[en ur].each do |locale|
    it "downloads from the #{locale} interface" do
      get "/#{locale}/desktop/windows"

      expect(response).to redirect_to(release[:assets].first[:browser_download_url])
    end
  end

  it "shares the cached release across platforms and locales" do
    get "/ar/desktop/windows"
    get "/en/desktop/macos"

    expect(api_request).to have_been_requested.once
  end

  context "when a new release is published" do
    let(:version) { "0.0.4" }

    it "uses its installer without a web app change" do
      get "/desktop/windows"

      expect(response).to redirect_to(release[:assets].first[:browser_download_url])
    end
  end

  it "does not route unsupported platforms" do
    get "/ar/desktop/linux"

    expect(response).to have_http_status(:not_found)
  end

  it "falls back to releases when the platform has no matching asset" do
    release[:assets].shift
    stub_request(:get, DesktopRelease::API_URL).to_return(body: release.to_json)
    get "/desktop/windows"

    expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
  end

  it "does not follow an asset URL outside the expected release" do
    release[:assets].first[:browser_download_url] = "https://example.com/untrusted.exe"
    stub_request(:get, DesktopRelease::API_URL).to_return(body: release.to_json)
    get "/desktop/windows"

    expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
  end

  [ nil, [], { tag_name: "v../other", assets: [] }, { tag_name: "v0.0.3", assets: nil }, { tag_name: "v0.0.3", assets: [ nil ] } ].each do |invalid_release|
    context "with malformed release metadata #{invalid_release.inspect}" do
      let(:release) { invalid_release }

      it "keeps the public releases page available" do
        get "/desktop/windows"

        expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
      end
    end
  end

  it "falls back when GitHub returns invalid JSON" do
    stub_request(:get, DesktopRelease::API_URL).to_return(body: "not json")
    get "/desktop/windows"

    expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
  end

  [ 403, 404, 503 ].each do |status|
    it "falls back when GitHub returns #{status}" do
      stub_request(:get, DesktopRelease::API_URL).to_return(status: status)
      get "/desktop/windows"

      expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
    end
  end

  [ Net::OpenTimeout, SocketError, Errno::ECONNRESET, Net::HTTPBadResponse, OpenSSL::SSL::SSLError ].each do |error|
    it "falls back when the release lookup raises #{error}" do
      stub_request(:get, DesktopRelease::API_URL).to_raise(error)
      get "/desktop/windows"

      expect(response).to redirect_to(DesktopRelease::RELEASES_URL)
    end
  end

  it "retries after a temporary lookup failure" do
    stub_request(:get, DesktopRelease::API_URL).to_return(status: 503).then.to_return(body: release.to_json)
    get "/desktop/windows"
    get "/desktop/windows"

    expect(response).to redirect_to(release[:assets].first[:browser_download_url])
  end
end
