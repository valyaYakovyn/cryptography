# frozen_string_literal: true

def str_to_num(str)
  str.bytes.reduce(0) { |total, byte| (total << 8) + byte }
end

def num_to_str(num)
  str = ''
  while num.positive?
    str = (num & 0xFF).chr + str
    num >>= 8
  end
  str
end

def mod_pow(base, exp, mod)
  result = 1
  base %= mod

  while exp.positive?
    result = (result * base) % mod if exp.odd?
    exp >>= 1
    base = (base * base) % mod
  end

  result
end

def is_prime?(num, iterations)
  return false if num < 2
  return true if num == 2
  return false if num.even?

  power = 0
  num_minus_one = num - 1
  while num_minus_one.even?
    power += 1
    num_minus_one >>= 1
  end

  iterations.times do
    random_val = 2 + rand(num - 4)
    mod_result = mod_pow(random_val, num_minus_one, num)

    next if mod_result == 1 || mod_result == num - 1

    (power - 1).times do
      mod_result = mod_pow(mod_result, 2, num)
      return false if mod_result == 1
      break if mod_result == num - 1
    end

    return false if mod_result != num - 1
  end

  true
end

def generate_prime(bit_size)
  begin
    prime = rand(2**(bit_size - 1)..2**bit_size)
  end until prime.odd? && is_prime?(prime, 5)
  prime
end

def extended_gcd(a, b)
  x = 1
  last_x = 0
  y = 0
  last_y = 1

  while b != 0
    quotient, remainder = a.divmod(b)
    a = b
    b = remainder
    x, last_x = last_x, x - quotient * last_x
    y, last_y = last_y, y - quotient * last_y
  end

  [x, y]
end

def mod_inv(num, mod)
  x, = extended_gcd(num, mod)
  x %= mod
  x += mod if x.negative?
  x
end

def choose_e(phi)
  e = rand(2..phi - 1)
  e += 1 until e.gcd(phi) == 1
  e
end

def encrypt(msg, e, n)
  mod_pow(msg, e, n)
end

def decrypt(ciphertext, d, n)
  mod_pow(ciphertext, d, n)
end

bit_size = 512
p = generate_prime(bit_size)
q = generate_prime(bit_size)

n = p * q
phi = (p - 1) * (q - 1)

e = choose_e(phi)
d = mod_inv(e, phi)

puts "Public Key: (#{e}, #{n})"
puts "Private Key: (#{d}, #{n})\n\n"

message = 'Are you sure about that?'
message_num = str_to_num(message)

encrypted = encrypt(message_num, e, n)
puts "Encrypted Message: #{encrypted}"

decrypted_num = decrypt(encrypted, d, n)
decrypted_message = num_to_str(decrypted_num)
puts "Decrypted Message: #{decrypted_message}"
