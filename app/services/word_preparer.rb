# frozen_string_literal: true

class WordPreparer
  TOOL_WORDS = %w[et que qui est sont avec pour dans
                  mais alors aussi chez].freeze

  CHAR_RELOU = 'ɛ̃'.chars[1]

  SPECIAL_PHONEMES = [
    ['ɑ̃', 'orange', /(?<!ai)(an|em|en|am)(?!e|a)/, '<span class="orange">\1</span>'],
    ['u', 'red', /(ou)/, '<span class="red">\1</span>'],
    ['wa', 'black', /(oi)/, '<span class="black">\1</span>'],
    ['ɔ̃', 'brown', /(on|om)/, '<span class="brown">\1</span>'],
    ['ɛ', 'purple', /(ai|ei)/, '<span class="purple">\1</span>'],
    ['ɛ̃', 'green', /((a|e)?in)/, '<span class="green">\1</span>'],
    ['o', 'pink', /(eau|au)/, '<span class="pink">\1</span>'],
    ['ø', 'blue', /(eu)/, '<span class="blue">\1</span>'],
    ['œ', 'blue', /(eu)/, '<span class="blue">\1</span>']
  ].freeze

  def redis_client
    @redis_client ||= Redis.new
  end

  def prepare_word(word, phonemized_word)
    return nil if word.blank?
    return word if phonemized_word.blank?

    return "<span class=\"tool-word\">#{word}</span>" if TOOL_WORDS.include?(word.downcase)

    prepared_word = word
    SPECIAL_PHONEMES.each do |phoneme, color, regexp, replace|
      if word_contains_phoneme(phonemized_word, phoneme)
        prepared_word = prepared_word.gsub(regexp, replace)
      end
    end

    prepared_word
  end

  # def word_contains_phoneme(word_phonemes, phoneme):
  #     # print(f'checking if word {word_phonemes} contains phoneme {phoneme}')
  #     word_phonemes_chars = list(word_phonemes)
  #     phoneme_chars = list(phoneme)
  #     # print(f'\tchecking if word {word_phonemes_chars} contains phoneme {phoneme_chars}')
  #     # for each position in the word, check if the array matches
  #     for i in range(len(word_phonemes_chars)-len(phoneme_chars)+1):
  #         for j in range(len(phoneme_chars)):
  #             # print(f'checking word {word_phonemes_chars} at position {i+j} with phoneme {phoneme_chars} at position {j}')
  #             if word_phonemes_chars[i+j] != phoneme_chars[j]:
  #                 break
  #             if j == len(phoneme_chars)-1 and (len(word_phonemes_chars) <= i+j+1 or word_phonemes_chars[i+j+1] != CHAR_RELOU):
  #                 return True
  def word_contains_phoneme(word_phonemes, phoneme) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    word_phonemes_chars = word_phonemes.chars
    phoneme_chars = phoneme.chars

    (word_phonemes_chars.length - phoneme_chars.length + 1).times do |i|
      phoneme_chars.length.times do |j|
        break if word_phonemes_chars[i + j] != phoneme_chars[j]

        if j == phoneme_chars.length - 1 &&
           (word_phonemes_chars.length <= i + j + 1 || word_phonemes_chars[i + j + 1] != CHAR_RELOU)
          return true
        end
      end
    end
    false
  end

  def prepare(text)
    words = text.split

    # get phonemized words from Redis
    phonemized_pairs = words.map { |word| [word, redis_client.get(word.downcase)] }

    # prepare words
    phonemized_pairs.map { |word, phonemized_word| prepare_word(word, phonemized_word) }.join(' ')
  end
end
