# frozen_string_literal: true

S_BOX = Array.new(8) { Array.new(64, 0) }

S_BOX[0] = [14,  4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
            0, 15,  7,  4, 14,  2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
            4,  1, 14,  8, 13,  6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
            15, 12,  8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13]

S_BOX[1] = [15,  1,  8, 14,  6, 11, 3, 4, 9, 7,  2, 13, 12, 0, 5, 10,
            3, 13,  4,  7, 15,  2, 8, 14, 12, 0, 1, 10,  6, 9, 11, 5,
            0, 14,  7, 11, 10,  4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
            13,  8, 10,  1,  3, 15,  4,  2, 11,  6,  7, 12, 0,  5, 14, 9]

S_BOX[2] = [10,  0,  9, 14,  6,  3, 15,  5,  1, 13, 12, 7, 11, 4, 2, 8,
            13,  7,  0,  9,  3,  4,  6, 10,  2,  8,  5, 14, 12, 11, 15, 1,
            13,  6,  4,  9,  8, 15,  3,  0, 11,  1,  2, 12, 5, 10, 14, 7,
            1, 10, 13, 0, 6,  9, 8,  7,  4, 15, 14,  3, 11, 5,  2, 12]

S_BOX[3] = [7, 13, 14,  3,  0,  6, 9, 10,  1,  2,  8,  5, 11, 12,  4, 15,
             13,  8, 11, 5, 6, 15,  0,  3, 4, 7, 2, 12, 1, 10, 14, 9,
             10,  6, 9,  0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
             3, 15,  0,  6, 10,  1, 13,  8,  9,  4,  5, 11, 12,  7, 2, 14]

S_BOX[4] = [2, 12,  4,  1,  7, 10, 11,  6,  8,  5,  3, 15, 13,  0, 14, 9,
             14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
             4,  2,  1, 11, 10, 13, 7,  8, 15, 9, 12, 5,  6, 3, 0, 14,
             11,  8, 12,  7,  1, 14, 2, 13, 6, 15, 0, 9, 10, 4,  5,  3]

S_BOX[5] = [12,  1, 10, 15,  9,  2,  6,  8,  0, 13,  3,  4, 14,  7,  5, 11,
            10, 15, 4, 2,  7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
            9, 14, 15, 5,  2,  8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
            4,  3, 2, 12,  9,  5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13]

S_BOX[6] = [4, 11,  2, 14, 15,  0,  8, 13,  3, 12,  9,  7,  5, 10,  6,  1,
             13,  0, 11,  7,  4, 9,  1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
             1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
             6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12]

S_BOX[7] = [13, 2,  8,  4,  6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
            1, 15, 13,  8, 10, 3, 7,  4, 12, 5, 6, 11, 0, 14, 9, 2,
            7, 11,  4,  1,  9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
            2,  1, 14,  7,  4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11]

SubKeyMatrix = Array.new(16) { Array.new(8) }

InitialPermutationTable = [58, 50, 42, 34, 26, 18, 10, 2,
                           60, 52, 44, 36, 28, 20, 12, 4,
                           62, 54, 46, 38, 30, 22, 14, 6,
                           64, 56, 48, 40, 32, 24, 16, 8,
                           57, 49, 41, 33, 25, 17, 9, 1,
                           59, 51, 43, 35, 27, 19, 11, 3,
                           61, 53, 45, 37, 29, 21, 13, 5,
                           63, 55, 47, 39, 31, 23, 15, 7].freeze

ExpansionPermutationTable = [32, 1, 2, 3, 4, 5,
                             4,  5, 6,  7, 8, 9,
                             8,  9, 10, 11, 12, 13,
                             12, 13, 14, 15, 16, 17,
                             16, 17, 18, 19, 20, 21,
                             20, 21, 22, 23, 24, 25,
                             24, 25, 26, 27, 28, 29,
                             28, 29, 30, 31, 32, 1].freeze

PermutationFunctionTable = [16,  7, 20, 21, 29, 12, 28, 17,
                            1, 15, 23, 26,  5, 18, 31, 10,
                            2,  8, 24, 14, 32, 27, 3, 9,
                            19, 13, 30, 6, 22, 11, 4, 25].freeze

FinalPermutationTable = [40, 8, 48, 16, 56, 24, 64, 32,
                         39, 7, 47, 15, 55, 23, 63, 31,
                         38, 6, 46, 14, 54, 22, 62, 30,
                         37, 5, 45, 13, 53, 21, 61, 29,
                         36, 4, 44, 12, 52, 20, 60, 28,
                         35, 3, 43, 11, 51, 19, 59, 27,
                         34, 2, 42, 10, 50, 18, 58, 26,
                         33, 1, 41, 9, 49, 17, 57, 25].freeze

PermutationChoice1Table = [57, 49, 41, 33, 25, 17,  9,
                           1, 58, 50, 42, 34, 26, 18,
                           10, 2, 59, 51, 43, 35, 27,
                           19, 11, 3, 60, 52, 44, 36,
                           63, 55, 47, 39, 31, 23, 15,
                           7, 62, 54, 46, 38, 30, 22,
                           14, 6, 61, 53, 45, 37, 29,
                           21, 13, 5, 28, 20, 12,  4].freeze

PermutationChoice2Table = [14, 17, 11, 24, 1, 5, 3, 28,
                           15,  6, 21, 10, 23, 19, 12,  4,
                           26,  8, 16,  7, 27, 20, 13,  2,
                           41, 52, 31, 37, 47, 55, 30, 40,
                           51, 45, 33, 48, 44, 49, 39, 56,
                           34, 53, 46, 42, 50, 36, 29, 32].freeze

LeftShiftTable = [1, 1, 2, 2,
                  2, 2, 2, 2,
                  1, 2, 2, 2,
                  2, 2, 2, 1].freeze

def bits_to_bytes(bits)
  bits.each_slice(8).map { |slice| slice.join.to_i(2) }
end

def bytes_to_bits(bytes)
  bytes.flat_map do |byte|
    byte = [true, false].include?(byte) ? byte ? 1 : 0 : byte
    8.times.map { |bit| (byte >> (7 - bit)) & 0x01 }
  end
end

def apply_permutation(bits, permutation)
  permutation.map { |index| bits[index - 1] }
end

def permute_bytes(bytes, permutation)
  result = Array.new(permutation.length / 8, 0)
  permutation.each_with_index do |pos, index|
    byte_index = (pos - 1) / 8
    bit_index = (pos - 1) % 8
    result_index = index / 8
    bit_shift = index % 8 - bit_index
    bit = bytes[byte_index] & (128 >> bit_index)
    result[result_index] |= bit_shift >= 0 ? bit >> bit_shift : bit << -bit_shift
  end
  result
end

def calculate_index(bits)
  bits[0] << 5 | bits[1] << 3 | bits[2] << 2 | bits[3] << 1 | bits[4] | bits[5] << 4
end

def add_padding(str)
  padding_size = 8 - str.length % 8
  str.bytes + Array.new(padding_size, padding_size)
end

def remove_padding(bytes)
  bytes[0...-bytes.last].map(&:chr).join
end

def circular_left_shift(key_bits, round)
  shift_amount = LeftShiftTable[round]
  key_bits[0...28].rotate(shift_amount) + key_bits[28...56].rotate(shift_amount)
end

def generate_subkeys(key)
  bytes = key.is_a?(String) ? key.scan(/../).map(&:hex) : key
  raise ArgumentError, 'Key must be a hexadecimal string or an array of byte values' unless bytes.is_a?(Array)

  key_bits = bytes_to_bits(bytes)
  permuted_bits = apply_permutation(key_bits, PermutationChoice1Table)

  16.times do |round|
    shifted_bits = circular_left_shift(permuted_bits, round)
    SubKeyMatrix[round] = bits_to_bytes(apply_permutation(shifted_bits, PermutationChoice2Table))
    permuted_bits = shifted_bits
  end

  SubKeyMatrix
end

def block_encrypt(block)
  permuted_block = permute_bytes(block, InitialPermutationTable)
  left, right = permuted_block.each_slice(4).to_a

  16.times do |round|
    expanded_right = permute_bytes(right, ExpansionPermutationTable)
    mixed_bits = bytes_to_bits(expanded_right.zip(SubKeyMatrix[round]).map { |a, b| a ^ b })

    s_box_result = 4.times.map do |i|
      left_index = calculate_index(mixed_bits[i*12, 6])
      right_index = calculate_index(mixed_bits[i*12 + 6, 6])
      (S_BOX[i * 2][left_index] << 4) + S_BOX[i * 2 + 1][right_index]
    end

    permuted_s_box = permute_bytes(s_box_result, PermutationFunctionTable)
    new_right = permuted_s_box.zip(left).map { |a, b| a ^ b }
    left = right
    right = new_right
  end

  permute_bytes(right + left, FinalPermutationTable)
end

def block_decrypt(block)
  permuted_block = permute_bytes(block, InitialPermutationTable)
  left, right = permuted_block.each_slice(4).to_a

  16.times do |round|
    expanded_right = permute_bytes(right, ExpansionPermutationTable)
    mixed_bits = bytes_to_bits(expanded_right.zip(SubKeyMatrix[15 - round]).map { |a, b| a ^ b })

    s_box_result = 4.times.map do |i|
      left_index = calculate_index(mixed_bits[i*12, 6])
      right_index = calculate_index(mixed_bits[i*12 + 6, 6])
      (S_BOX[i * 2][left_index] << 4) + S_BOX[i * 2 + 1][right_index]
    end

    permuted_s_box = permute_bytes(s_box_result, PermutationFunctionTable)
    new_right = permuted_s_box.zip(left).map { |a, b| a ^ b }
    left = right
    right = new_right
  end

  permute_bytes(right + left, FinalPermutationTable)
end

def encrypt_string(key, string)
  generate_subkeys(key)
  padded_bytes = add_padding(string)
  encrypted_bytes = []

  padded_bytes.each_slice(8) do |block|
    encrypted_bytes += block_encrypt(block)
  end

  encrypted_bytes
end

def decrypt_string(key, bytes)
  generate_subkeys(key)
  decrypted_bytes = bytes.each_slice(8).flat_map { |block| block_decrypt(block) }
  remove_padding(decrypted_bytes)
end

encryption_key = '6D0D71320E2EA923'
plaintext = '456A536BCD132123'.bytes
ciphertext = encrypt_string(encryption_key, plaintext.pack('c*'))

puts "Plaintext: #{plaintext}"
puts "Ciphertext: #{ciphertext}"
puts "Decrypted: #{decrypt_string(encryption_key, ciphertext).bytes}"
