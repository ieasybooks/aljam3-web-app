require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'http://localhost:7701')

RSpec.configure do |config|
  config.before do
    WebMock.reset!
  end
end
