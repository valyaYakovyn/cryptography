# frozen_string_literal: true

def left_rotate(value, shift)
  ((value << shift) | (value >> (32 - shift))) & 0xffffffff
end

def sha1(message)
  message_bits = "#{message.unpack1('B*')}1#{'0' * ((448 - message.length * 8 - 1) % 512)}#{[message.length * 8].pack('Q>').unpack1('B*')}"
  blocks = message_bits.scan(/.{512}/)

  h = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0]

  blocks.each do |block|
    w = (0..15).map { |i| block[i * 32, 32].to_i(2) } + Array.new(64, 0)
    (16..79).each { |i| w[i] = left_rotate(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1) }

    a, b, c, d, e = h
    80.times do |i|
      f, k = if i < 20
               [(b & c) | (~b & d), 0x5A827999]
             elsif i < 40
               [b ^ c ^ d, 0x6ED9EBA1]
             elsif i < 60
               [(b & c) | (b & d) | (c & d), 0x8F1BBCDC]
             else
               [b ^ c ^ d, 0xCA62C1D6]
             end

      temp = left_rotate(a, 5) + f + e + k + w[i]
      e = d
      d = c
      c = left_rotate(b, 30)
      b = a
      a = temp & 0xffffffff
    end

    h[0] = (h[0] + a) & 0xffffffff
    h[1] = (h[1] + b) & 0xffffffff
    h[2] = (h[2] + c) & 0xffffffff
    h[3] = (h[3] + d) & 0xffffffff
    h[4] = (h[4] + e) & 0xffffffff
  end

  h.map { |x| '%08x' % x }.join
end

text = 'Secret password)'

puts "Text: #{text}"
puts "SHA1: #{sha1(text)}"
