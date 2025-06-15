require "rails_helper"
require_relative "../../script/ssh_client"

RSpec.describe SshClient do
  subject(:ssh_client) { described_class.new }

  describe "#execute_with_output" do
    let(:ssh_session) { instance_double(Net::SSH::Connection::Session) }
    let(:channel) { instance_double(Net::SSH::Connection::Channel) }

    before do
      allow(Net::SSH).to receive(:start).and_yield(ssh_session)
      allow(ssh_session).to receive(:open_channel).and_yield(channel)
      allow(ssh_session).to receive(:loop)
      allow(channel).to receive(:exec).and_yield(channel, true)
      allow(channel).to receive(:on_data)
      allow(channel).to receive(:on_extended_data)
    end

    it "executes command via SSH" do
      expect { |b| ssh_client.execute_with_output("127.0.0.1", "root", "test command", &b) }.not_to raise_error
    end

    context "when command execution fails" do
      before do
        allow(channel).to receive(:exec).and_yield(channel, false)
      end

      it "raises RuntimeError" do
        expect { ssh_client.execute_with_output("127.0.0.1", "root", "test command") }
          .to raise_error(RuntimeError)
      end
    end
  end
end
