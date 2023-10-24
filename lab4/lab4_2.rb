# frozen_string_literal: true

def gcdex(a, b)
  x = 1
  y = 0
  x1 = 0
  y1 = 1

  while b != 0
    q = a / b
    a, b = b, a % b
    x, x1 = x1, x - q * x1
    y, y1 = y1, y - q * y1
  end

  [a, x, y]
end

def inverse_element(a, n)
  gcd, x, = gcdex(a, n)
  gcd == 1 ? x % n : "Element doesn't have an inverse modulo n"
end

a = 5
n = 18
puts "The multiplicative inverse of #{a} mod #{n} is #{inverse_element(a, n)}"
