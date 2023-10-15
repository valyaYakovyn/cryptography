# frozen_string_literal: true

ALPHABET = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'

def vigenere(text, key, encrypt: true)
  key_len = key.length

  text.downcase.chars.each_with_index.map do |char, i|
    if ALPHABET.include?(char)
      key_char = key[i % key_len]
      shift = ALPHABET.index(key_char)
      operation = encrypt ? :+ : :-
      ALPHABET[ALPHABET.index(char).send(operation, shift) % ALPHABET.length]
    else
      char
    end
  end.join
end

p 'Введіть текст для зашифрування:'
text = gets.strip

p 'Введіть ключове слово:'
key = gets.strip

# Шифрування
encrypted_text = vigenere(text, key)
p "Зашифрований текст: #{encrypted_text}"

# Розшифрування
decrypted_text = vigenere(encrypted_text, key, encrypt: false)
p "Розшифрований текст: #{decrypted_text}"
