# frozen_string_literal: true

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

m = 18
puts "The value of Euler's totient function for #{m} is #{phi(m)}"
