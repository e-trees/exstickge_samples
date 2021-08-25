#!/usr/bin/ruby

require "socket"

udp = UDPSocket.open()
udp.bind("0.0.0.0", 0x4000)

prev = 0
while true
  data = udp.recv(65535)
  c = data[4..8].unpack("N*")[0]
  diff = c - prev
  if prev == 0 then
    diff = " -- "
  elsif diff < 0 then
    diff = "overflow"
  end
  puts("#{data[0..3]}: counter=#{c}, diff=#{diff}")
  prev = c
end
