# frozen_string_literal: true

def modular_pow(base, exponent, mod)
  result = 1
  base_mod = base % mod

  while exponent.positive?
    result = (result * base_mod) % mod if exponent.odd?
    exponent >>= 1
    base_mod = (base_mod * base_mod) % mod
  end

  result
end

def prime_test(num, iterations)
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
    random_num = 2 + rand(num - 4)
    mod_pow_result = modular_pow(random_num, num_minus_one, num)

    next if mod_pow_result == 1 || mod_pow_result == num - 1

    (power - 1).times do
      mod_pow_result = modular_pow(mod_pow_result, 2, num)
      return false if mod_pow_result == 1
      break if mod_pow_result == num - 1
    end

    return false if mod_pow_result != num - 1
  end

  true
end

number_to_test = 41
num_iterations = 10
if prime_test(number_to_test, num_iterations)
  puts "#{number_to_test} is probably a prime number with a probability of #{(1 - 4.0**-num_iterations).round(10)}"
else
  puts "#{number_to_test} is a composite number"
end
