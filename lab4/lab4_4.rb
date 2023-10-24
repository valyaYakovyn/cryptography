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

def phi(m)
  result = m
  2.upto(Math.sqrt(m).to_i) do |p|
    if (m % p).zero?
      result -= result / p
      m /= p while (m % p).zero?
    end
  end
  result -= result / m if m > 1
  result
end

def inverse_element_2(a, n)
  gcd, = gcdex(a, n)
  if gcd != 1
    "Element doesn't have an inverse modulo n"
  else
    a.pow(phi(n) - 1, n)
  end
end

a = 5
n = 18
puts "The multiplicative inverse of #{a} mod #{n} is #{inverse_element_2(a, n)}"
