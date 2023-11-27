# frozen_string_literal: true

def is_number_prime?(number, test_rounds = 100)
  return false if number <= 1 || number == 4
  return true if number <= 3

  num_sub_one = number - 1
  num_sub_one /= 2 while num_sub_one.even?

  test_rounds.times do
    random_val = 2 + rand(number - 4)
    power_result = random_val.pow(num_sub_one, number)
    next if power_result == 1 || power_result == number - 1

    while num_sub_one != number - 1
      power_result = power_result.pow(2, number)
      num_sub_one *= 2
      return true if power_result == 1
      return false if power_result == number - 1
    end

    return false
  end

  true
end

def create_large_prime(num_bits)
  loop do
    prime_candidate = Random.rand(2**(num_bits - 1)..2**num_bits - 1) | 1
    return prime_candidate if is_number_prime?(prime_candidate)
  end
end

def find_primitive_root(prime)
  return 2 if [2, 3].include?(prime)

  phi = prime - 1
  prime_factors_list = find_prime_factors(phi)

  (2...prime).each do |potential_root|
    return potential_root if prime_factors_list.none? { |factor| potential_root.pow(phi / factor, prime) == 1 }
  end
end

def find_prime_factors(number)
  factors = []
  divisor = 2
  while divisor * divisor <= number
    while (number % divisor).zero?
      factors << divisor
      number /= divisor
    end
    divisor += 1
  end
  factors << number if number > 1
  factors.uniq
end

def generate_key_pair(prime, base)
  private_key = rand(2...prime - 1)
  public_key = base.pow(private_key, prime)
  [private_key, public_key]
end

prime = create_large_prime(64)
base = find_primitive_root(prime)

puts "p = #{prime}"
puts "g = #{base}"

alice_keys = generate_key_pair(prime, base)
bob_keys = generate_key_pair(prime, base)

puts "\nAlice: \tPrivate Key: #{alice_keys[0]} \tPublic Key: #{alice_keys[1]}"
puts "Bob: \tPrivate Key: #{bob_keys[0]} \tPublic Key: #{bob_keys[1]}"

alice_shared_secret = bob_keys[1].pow(alice_keys[0], prime)
bob_shared_secret = alice_keys[1].pow(bob_keys[0], prime)

if alice_shared_secret == bob_shared_secret
  puts "\nKey exchange successful. Shared Secret Key: #{alice_shared_secret}"
else
  puts 'Key exchange error.'
end
