require 'socket'
require './types_pb.rb'
require './counter.rb'

server = TCPServer.new 46658

loop do
  client = server.accept

  # bytes = []
  byte = client.recv(256)

  # if byte.length <= 255
  #   bytes << byte
  # else
  #   while byte.length >= 254
  #     bytes << byte
  #     byte = client.recv(256)
  #   end
  # end
  #
  # bytes.each do |byte|
    byte = byte.to_s[2..-5]
    m = Types::Request.decode(byte)

    if m.info
      r = Counter.info(m.info)
      rmes = Types::Response.new
      rmes.info = r
    elsif m.echo
      r = Counter.echo(m.echo)
      rmes = Types::Response.new
      rmes.echo = r
      p rmes
    elsif m.flush
      nil
    elsif m.set_option
      r = Counter.set_option(m.set_option, m)
      rmes = Types::Response.new
      rmes.set_option = r
    elsif m.deliver_tx
      r = Counter.deliver_tx(m.deliver_tx, m)
      rmes = Types::Response.new
      rmes.deliver_tx = r
    elsif m.check_tx
      r = Counter.check_tx(m.check_tx, m)
      rmes = Types::Response.new
      rmes.check_tx = r
    elsif m.commit
      r = Counter.commit(m.commit, m)
      rmes = Types::Response.new
      rmes.commit = r
    elsif m.query
      nil
    elsif m.init_chain
      nil
    elsif m.begin_block
      r = Counter.begin_block(m.begin_block, m)
      rmes = Types::Response.new
      rmes.begin_block = r
    elsif m.end_block
      r = Counter.end_block(m.end_block, m)
      rmes = Types::Response.new
      rmes.end_block = r
    end

    rcode = Types::Response.encode(rmes)

    byte_array = []

    l = rcode.length
    byte_array[1] = l
    p l

    lengtharr = []
    lengtharr << l
    ll = lengtharr.pack("C*").length
    byte_array[0] = ll

    rcode.bytes.each do |byte|
      byte_array << byte
    end

    p byte_array

    rcode = byte_array.pack("C*")

    p rcode

    client.send(rcode, 0)
  # end
  client.close
end
