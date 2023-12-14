# frozen_string_literal: true

require 'openssl'

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

  h.map { |x| format('%08x', x) }.join
end

def invmod(e, et)
  g, x = extended_gcd(e, et)
  raise 'The inverse does not exist' if g != 1

  x % et
end

def extended_gcd(a, b)
  return [b, 0, 1] if (a % b).zero?

  g, x, y = extended_gcd(b, a % b)
  [g, y, x - y * (a / b)]
end

def pow_mod(base, exponent, mod)
  result = 1
  base %= mod

  while exponent.positive?
    result = (result * base) % mod if exponent.odd?
    exponent >>= 1
    base = (base * base) % mod
  end

  result
end

def is_prime?(n, k = 10)
  return false if n <= 1 || n.even? && n != 2
  return true if n <= 3

  d = n - 1
  r = 0
  d /= 2 while d.even? && (r += 1)

  k.times do
    a = rand(2..n - 2)
    x = pow_mod(a, d, n)
    next if x == 1 || x == n - 1

    (r - 1).times do
      x = pow_mod(x, 2, n)
      return false if x == 1
      break if x == n - 1
    end

    return false if x != n - 1
  end

  true
end

def generate_prime(bits)
  loop do
    n = OpenSSL::BN.rand(bits).to_i | 1 | (1 << bits - 1)
    return n if is_prime?(n)
  end
end

def generate_params
  q = generate_prime(1024)
  p = generate_prime_with_condition(q)
  g = find_generator(p, q)

  [p, q, g]
end

def generate_prime_with_condition(q)
  loop do
    k = rand(2**512...2**1024)
    p = k * q + 1
    return p if is_prime?(p)
  end
end

def find_generator(p, q)
  (2...p - 1).each do |h|
    g = h.pow((p - 1) / q, p)
    return g if g > 1
  end
end

def generate_keys(g, p, q)
  x = 12_496 # rand(2...q)
  y = g.pow(x, p)
  [x, y]
end

def sign(message, p, q, g, x)
  loop do
    k = 9557 # rand(1...q)
    r = g.pow(k, p) % q
    next if r.zero?

    k_inv = invmod(k, q)
    hash = 5246 # sha1(message).to_i(16)
    s = (k_inv * (hash + x * r)) % q
    return [r, s] unless s.zero?
  end
end

def verify(message, r, s, p, q, g, y)
  return false if r <= 0 || r >= q || s <= 0 || s >= q

  w = invmod(s, q)
  hash = 5246 # sha1(message).to_i(16)
  u1 = (hash * w) % q
  u2 = (r * w) % q
  v = ((g.pow(u1, p) * y.pow(u2, p)) % p) % q

  v == r
end

p = 124_540_019
q = 17_389
g = 110_217_528.pow((p - 1) / q, p)
# p, g, q = generate_params

x, y = generate_keys(g, p, q)

puts "Public key: (#{p}, #{q}, #{g}, #{y})"
puts "Private key: #{x}"

message = 'Very secret test message'
r, s = sign(message, p, q, g, x)
puts "Signature: (#{r}, #{s})"

valid = verify(message, r, s, p, q, g, y)

puts "Verified signature: #{valid}"
