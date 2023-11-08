# frozen_string_literal: true

def euclid_gcd(a, b)
  b.zero? ? a : euclid_gcd(b, a % b)
end

def mod_inverse(a, modulus)
  return nil if euclid_gcd(a, modulus) != 1

  (1..modulus).detect { |i| (a * i) % modulus == 1 }
end

def encrypt_affine(text, key_a, key_b, alphabet_size)
  text.chars.map do |char|
    if char =~ /[A-Za-z]/
      (('a'.ord + (key_a * (char.downcase.ord - 'a'.ord) + key_b) % alphabet_size)).chr
    else
      char
    end
  end.join
end

def decrypt_affine(encrypted_text, key_a, key_b, alphabet_size)
  key_a_inv = mod_inverse(key_a, alphabet_size)
  raise 'No inverse for key_a exists' unless key_a_inv

  encrypted_text.chars.map do |char|
    if char =~ /[A-Za-z]/
      (('a'.ord + (key_a_inv * (char.downcase.ord - 'a'.ord - key_b)) % alphabet_size)).chr
    else
      char
    end
  end.join
end

key_a = 11
key_b = 5
n = 26

original_text = 'crypto'
encrypted = encrypt_affine(original_text, key_a, key_b, n)
puts "Encrypted: #{encrypted}"

decrypted = decrypt_affine(encrypted, key_a, key_b, n)
puts "Decrypted: #{decrypted}"
