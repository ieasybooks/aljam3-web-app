require "webmock/minitest"

WebMock.disable_net_connect!(allow_localhost: true, allow: [ "http://localhost:7701", "https://clerk-1.avohq.io", "https://clerk-2.avohq.io" ])
