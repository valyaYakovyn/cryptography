# frozen_string_literal: true

def mul02(elem)
  result = (elem << 1) ^ (elem & 0x80 != 0 ? 0x11b : 0)
  result & 0xff
end

def mul03(elem)
  mul02(elem) ^ elem
end

elem1 = 0xD4
elem2 = 0xBF

puts mul02(elem1).to_s(16)
puts mul03(elem2).to_s(16)
