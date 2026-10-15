require "test_helper"
require_relative "../../script/ssh_client"

class SshClientTest < ScriptTest
  test "executes a command and yields standard and extended output" do
    channel = mock("channel")
    ssh = mock("ssh")
    channel.stubs(:on_data).yields(channel, "stdout")
    channel.stubs(:on_extended_data).yields(channel, 1, "stderr")
    channel.expects(:exec).with("ls").yields(channel, true)
    ssh.expects(:open_channel).yields(channel)
    ssh.expects(:loop)
    Net::SSH.expects(:start).with("host", "user", password: nil).yields(ssh)

    output = []
    SshClient.new.execute_with_output("host", "user", "ls") { |data| output << data }

    assert_equal [ "stdout", "stderr" ], output
  end

  test "raises when SSH cannot execute the command" do
    channel = mock("channel")
    ssh = mock("ssh")
    channel.expects(:exec).with("bad").yields(channel, false)
    ssh.expects(:open_channel).yields(channel)
    Net::SSH.expects(:start).yields(ssh)

    error = assert_raises(RuntimeError) { SshClient.new.execute_with_output("host", "user", "bad") }
    assert_includes error.message, "Could not execute command"
  end
end
