require 'socket'
require 'timeout'


class GexUtils

  def self.is_port_open?(ip, port, milliseconds = 5000)
    (1..(milliseconds / 100)).each do
      puts "Checking open port #{ip}:#{port}"
      Timeout::timeout(10) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          sleep 0.1
        end
      end
    end
    false
  end


end