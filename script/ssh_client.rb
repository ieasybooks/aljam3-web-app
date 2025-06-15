require "net/ssh"

class SshClient
  def execute_with_output(server_ip, username, command)
    Net::SSH.start(server_ip, username, password: nil) do |ssh|
      ssh.open_channel do |channel|
        channel.exec(command) do |_ch, success|
          raise RuntimeError, "Could not execute command: #{command.inspect}" unless success

          channel.on_data { |_ch, data| yield(data) }
          channel.on_extended_data { |_ch, _type, data| yield(data) }
        end
      end

      ssh.loop
    end
  end
end
