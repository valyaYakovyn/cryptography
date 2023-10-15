# frozen_string_literal: true

def encrypt(text, key_row, key_col)
  encrypted_text = ''
  rows_amount = key_row.length
  cols_amount = key_col.length
  text_matrix = Array.new(rows_amount) { Array.new(cols_amount, ' ') }
  index = 0

  rows_amount.times do |i|
    cols_amount.times do |j|
      text_matrix[i][j] = text[index] if index < text.length
      index += 1
    end
  end

  sorted_matrix_by_rows = text_matrix.sort_by.with_index { |_, i| key_row[i] }
  sorted_matrix = sorted_matrix_by_rows.transpose.sort_by.with_index { |_, i| key_col[i] }
  sorted_matrix.each { |row| row.each { |ch| encrypted_text += ch } }

  encrypted_text
end

def decrypt(encrypted_text, key_row, key_col)
  decrypted_text = ''
  rows_amount = key_row.length
  cols_amount = key_col.length
  text_matrix = Array.new(cols_amount) { Array.new(rows_amount, ' ') }
  index = 0

  cols_amount.times do |i|
    rows_amount.times do |j|
      text_matrix[i][j] = encrypted_text[index] if index < encrypted_text.length
      index += 1
    end
  end

  text_matrix = text_matrix.transpose
  original_rows_order = key_row.chars.map.with_index.sort.map { |_, i| i }
  original_cols_order = key_col.chars.map.with_index.sort.map { |_, i| i }
  sorted_matrix_by_rows = text_matrix.sort_by.with_index { |_, i| original_rows_order[i] }
  sorted_matrix = sorted_matrix_by_rows.transpose.sort_by.with_index { |_, i| original_cols_order[i] }
  sorted_matrix = sorted_matrix.transpose
  sorted_matrix.each { |row| row.each { |ch| decrypted_text += ch } }

  decrypted_text
end


p 'Введіть текст для зашифрування:'
text = gets.strip
text_len = text.length
key_row_len = (text_len / 6.0).ceil
col_key = ''
row_key = ''

while col_key.length < 6
  p 'Введіть ключове слово по стовпцях (не менше 6 символів):'
  col_key = gets.strip[0, 6]
end

while row_key.length < key_row_len
  p "Введіть ключове слово по рядках (не менше #{key_row_len} символів):"
  row_key = gets.strip[0, key_row_len]
end

# Шифрування
encrypted_text = encrypt(text, row_key, col_key)
p "Зашифрований текст: #{encrypted_text}"

# Розшифрування
decrypted_text = decrypt(encrypted_text, row_key, col_key)
p "Розшифрований текст: #{decrypted_text}"
