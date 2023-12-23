# frozen_string_literal: true

puts '======================================== Lab 12_1 ========================================'

def find_curve_points(coeff_a, coeff_b, prime_modulus)
  curve_points = []
  (0...prime_modulus).each do |x_coord|
    equation_rhs = (x_coord**3 + coeff_a * x_coord + coeff_b) % prime_modulus
    (0...prime_modulus).each do |y_coord|
      curve_points << [x_coord, y_coord] if y_coord**2 % prime_modulus == equation_rhs
    end
  end
  curve_points
end

coeff_a = 1
coeff_b = 1
prime_modulus = 23

puts find_curve_points(coeff_a, coeff_b, prime_modulus).inspect

puts "\n\n\n"
puts '======================================== Lab 12_2 ========================================'

def extended_gcd(a, b)
  return [0, 1] if (a % b).zero?

  x, y = extended_gcd(b, a % b)
  [y, x - y * (a / b)]
end

def modular_inverse(number, modulus)
  x, = extended_gcd(number, modulus)
  (x % modulus + modulus) % modulus
end

def add_elliptic_curve_points(point1, point2, curve_coefficient_a, prime_modulus)
  return point2 if point1.nil?
  return point1 if point2.nil?

  if point1 == point2
    return nil if point1[1].zero?

    slope = (3 * point1[0]**2 + curve_coefficient_a) * modular_inverse(2 * point1[1], prime_modulus) % prime_modulus
  elsif point1[0] != point2[0]
    slope = (point2[1] - point1[1]) * modular_inverse(point2[0] - point1[0], prime_modulus) % prime_modulus
  else
    return nil
  end

  x_result = (slope**2 - point1[0] - point2[0]) % prime_modulus
  y_result = (slope * (point1[0] - x_result) - point1[1]) % prime_modulus

  [x_result, y_result]
end

def calculate_point_order(base_point, curve_coefficient_a, prime_modulus)
  current_point = base_point
  order = 1

  while current_point
    order += 1
    current_point = add_elliptic_curve_points(current_point, base_point, curve_coefficient_a, prime_modulus)
  end

  order
end

curve_coefficient = 1
prime_modulus = 23
base_point = [17, 20]

point_order = calculate_point_order(base_point, curve_coefficient, prime_modulus)
puts "Порядок n для базової точки генератора із координатами #{base_point.inspect}: #{point_order}"
