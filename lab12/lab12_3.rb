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
      f, k = case i
             when 0..19 then [(b & c) | (~b & d), 0x5A827999]
             when 20..39 then [b ^ c ^ d, 0x6ED9EBA1]
             when 40..59 then [(b & c) | (b & d) | (c & d), 0x8F1BBCDC]
             else [b ^ c ^ d, 0xCA62C1D6]
             end

      temp = left_rotate(a, 5) + f + e + k + w[i]
      e = d
      d = c
      c = left_rotate(b, 30)
      b = a
      a = temp & 0xffffffff
    end

    h = h.zip([a, b, c, d, e]).map { |x, y| (x + y) & 0xffffffff }
  end

  h.map { |x| format('%08x', x) }.join
end

def extended_gcd(a, b)
  return [0, 1] if (a % b).zero?

  x, y = extended_gcd(b, a % b)
  [y, x - y * (a / b)]
end

def modular_inverse(number, modulus)
  x, = extended_gcd(number, modulus)
  (x % modulus + modulus) % modulus
end

def generate_ecdsa_keys(base_point, curve_coefficient, prime_modulus, order)
  private_key = rand(1...order)
  public_key = multiply_point(base_point, private_key, curve_coefficient, prime_modulus)
  [private_key, public_key]
end

def add_points(point1, point2, curve_coefficient, prime_modulus)
  return point2 if point1.nil?
  return point1 if point2.nil?

  if point1 == point2
    return nil if point1[1].zero?

    slope = (3 * point1[0]**2 + curve_coefficient) * modular_inverse(2 * point1[1], prime_modulus) % prime_modulus
  elsif point1[0] != point2[0]
    slope = (point2[1] - point1[1]) * modular_inverse(point2[0] - point1[0], prime_modulus) % prime_modulus
  else
    return nil
  end

  x_result = (slope**2 - point1[0] - point2[0]) % prime_modulus
  y_result = (slope * (point1[0] - x_result) - point1[1]) % prime_modulus

  [x_result, y_result]
end

def double_point(point, curve_coefficient, prime_modulus)
  return nil if point.nil? || point[1].zero?

  slope = ((3 * point[0]**2 + curve_coefficient) * modular_inverse(2 * point[1], prime_modulus)) % prime_modulus
  x_result = (slope**2 - 2 * point[0]) % prime_modulus
  y_result = (slope * (point[0] - x_result) - point[1]) % prime_modulus

  [x_result, y_result]
end

def multiply_point(point, scalar, curve_coefficient, prime_modulus)
  result = nil
  scalar.to_s(2).each_char do |bit|
    result = double_point(result, curve_coefficient, prime_modulus)
    result = add_points(result, point, curve_coefficient, prime_modulus) if bit == '1'
  end
  result
end

def calculate_point_order(base_point, curve_coefficient, prime_modulus)
  current_point = base_point
  order = 1

  while current_point
    order += 1
    current_point = add_points(current_point, base_point, curve_coefficient, prime_modulus)
  end

  order
end

def ecdsa_sign(message, private_key, curve_coefficient, prime_modulus, base_point, order)
  message_hash = sha1(message).to_i(16)
  r = 0
  s = 0

  while r.zero? || s.zero?
    k = rand(1...order)
    x1, = multiply_point(base_point, k, curve_coefficient, prime_modulus)
    r = x1 % order
    next if r.zero?

    s = (modular_inverse(k, order) * (message_hash + private_key * r)) % order
  end

  [r, s]
end

def ecdsa_verify(message, r, s, public_key, curve_coefficient, prime_modulus, base_point, order)
  return false if [r, s].any? { |val| val <= 0 || val >= order }

  message_hash = sha1(message).to_i(16)
  w = modular_inverse(s, order)
  u1 = (message_hash * w) % order
  u2 = (r * w) % order
  x1, = add_points(multiply_point(base_point, u1, curve_coefficient, prime_modulus),
                   multiply_point(public_key, u2, curve_coefficient, prime_modulus), curve_coefficient, prime_modulus)
  x1 % order == r
end

curve_coefficient = 1
prime_modulus = 23
base_point = [17, 20]

order = calculate_point_order(base_point, curve_coefficient, prime_modulus)
puts "Порядок n для базової точки генератора із координатами #{base_point.inspect}: #{order}"

private_key, public_key = generate_ecdsa_keys(base_point, curve_coefficient, prime_modulus, order)
puts "Приватний ключ: #{private_key}"
puts "Публічний ключ: #{public_key}"

message = 'Secret password)'
puts "Повідомлення: \"#{message}\""

r, s = ecdsa_sign(message, private_key, curve_coefficient, prime_modulus, base_point, order)
puts "Підпис: (r: #{r}, s: #{s})"
puts "Підпис валідний?: #{if ecdsa_verify(message, r, s, public_key, curve_coefficient, prime_modulus, base_point,
                                          order)
                            'Так'
                          else
                            'Ні'
                          end}"
