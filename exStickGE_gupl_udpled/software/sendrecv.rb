#!/usr/bin/ruby

require "socket"

udp = UDPSocket.open()
sockaddr = Socket.pack_sockaddr_in(16384, "10.0.0.3")
16.times{|i|
  udp.send([i].pack("N*"), 0, sockaddr)
  data = udp.recv(65535)
  p data
  sleep(1)
}
udp.close
