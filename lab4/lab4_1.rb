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

a = 612
b = 342
d, x, y = gcdex(a, b)
puts "d = #{d}\nx = #{x}\ny = #{y}"
