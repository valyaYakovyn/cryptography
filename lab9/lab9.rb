# frozen_string_literal: true

require 'openssl'

def convert_string_to_byte_array(string)
  string.bytes
end

def convert_byte_array_to_string(byte_array)
  byte_array.pack('C*').force_encoding('utf-8')
end

def encrypt_text(public_key, text)
  byte_array = convert_string_to_byte_array(text)
  byte_array.map { |byte| encode_message(public_key, byte) }
end

def decrypt_text(private_key, encrypted_bytes, prime)
  decrypted_byte_array = encrypted_bytes.map { |encrypted_byte| decode_message(private_key, encrypted_byte, prime) }
  convert_byte_array_to_string(decrypted_byte_array)
end

def exponent_modulo(base, exponent, modulo)
  base.to_bn.mod_exp(exponent, modulo).to_i
end

def is_prime?(number, test_count = 10)
  return false if number < 2
  return true if number == 2
  return false if number.even?

  max_div = number - 1
  div_count = 0
  while max_div.even?
    max_div /= 2
    div_count += 1
  end

  test_count.times do
    random_num = 2 + rand(number - 4)
    result = exponent_modulo(random_num, max_div, number)
    next if result == 1 || result == number - 1

    (div_count - 1).times do
      result = exponent_modulo(result, 2, number)
      return false if result == 1
      break if result == number - 1
    end

    return false if result != number - 1
  end

  true
end

def create_large_prime(bit_size)
  prime_candidate = 0
  loop do
    prime_candidate = OpenSSL::BN.rand(bit_size, -1, false).to_i
    prime_candidate |= (1 << bit_size - 1) | 1
    break if is_prime?(prime_candidate)
  end
  prime_candidate
end

def find_generator(prime)
  phi = prime - 1
  factors = find_prime_factors(phi)
  (2..phi).each do |potential_gen|
    valid_generator = true
    factors.each do |factor|
      if exponent_modulo(potential_gen, phi / factor, prime) == 1
        valid_generator = false
        break
      end
    end
    return potential_gen if valid_generator
  end
end

def find_prime_factors(number)
  factors = []
  factor_candidate = 2
  while factor_candidate * factor_candidate <= number
    while (number % factor_candidate).zero?
      factors << factor_candidate unless factors.include?(factor_candidate)
      number /= factor_candidate
    end
    factor_candidate += 1
  end
  factors << number if number > 1
  factors
end

def generate_keypair(bit_size)
  prime = create_large_prime(bit_size)
  generator = find_generator(prime)
  private_key = rand(2...prime - 1)
  public_key = exponent_modulo(generator, private_key, prime)
  { public: [prime, generator, public_key], private: private_key }
end

def encode_message(public_key, text)
  prime, generator, public_key_component = public_key
  session_key = rand(2...prime - 1)
  part_a = exponent_modulo(generator, session_key, prime)
  part_b = (text * exponent_modulo(public_key_component, session_key, prime)) % prime
  [part_a, part_b]
end

def decode_message(private_key, encrypted_parts, prime)
  part_a, part_b = encrypted_parts
  shared_secret = exponent_modulo(part_a, private_key, prime)
  (part_b * exponent_modulo(shared_secret, prime - 2, prime)) % prime
end

keys = generate_keypair(64)
puts "Public Key: #{keys[:public]}"
puts "Private Key: #{keys[:private]}"

message = 'Very secret message)'
puts "\nMessage: #{message}"

encrypted_message = encrypt_text(keys[:public], message)
puts "\nEncrypted message: #{encrypted_message}"

decrypted_message = decrypt_text(keys[:private], encrypted_message, keys[:public][0])
puts "\nDecrypted message: #{decrypted_message}"
