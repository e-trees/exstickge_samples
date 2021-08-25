#!/usr/bin/ruby

require "socket"

udp = UDPSocket.open()
sockaddr = Socket.pack_sockaddr_in(16384, "10.0.0.3")
udp.send([0,1,2,3,4,5,6,7,8,9,10].pack("N*"), 0, sockaddr)
data = udp.recv(65535)
c = data[4..8].unpack("N*")[0]
puts("#{data[0..3]}: #{c}")
udp.close
