# frozen_string_literal: true

class WordPreparer
  TOOL_WORDS = %w[et que qui est sont avec pour dans
                  mais alors aussi chez].freeze

  CHAR_RELOU = 'ɛ̃'.chars[1]

  SPECIAL_PHONEMES = [
    ['ɑ̃', 'orange', /(?<!ai)(an|em|en|am)(?!e|a)/i, '<span class="orange">\1</span>'],
    ['u', 'red', /(ou)/i, '<span class="red">\1</span>'],
    ['wa', 'black', /(oi)/i, '<span class="black">\1</span>'],
    ['ɔ̃', 'brown', /(on|om)/i, '<span class="brown">\1</span>'],
    ['ɛ', 'purple', /(ai|ei)/i, '<span class="purple">\1</span>'],
    ['ɛ̃', 'green', /((a|e)?in)/i, '<span class="green">\1</span>'],
    ['o', 'pink', /(eau|au)/i, '<span class="pink">\1</span>'],
    ['ø', 'blue', /(eu)/i, '<span class="blue">\1</span>'],
    ['œ', 'blue', /(eu)/i, '<span class="blue">\1</span>']
  ].freeze

  def redis_client
    @redis_client ||= Redis.new
  end

  def prepare_word(word, phonemized_word)
    return word if word.match?(/\W/)
    return word if phonemized_word.blank?

    return "<span class=\"tool-word\">#{word}</span>" if TOOL_WORDS.include?(word.downcase)

    prepared_word = word
    SPECIAL_PHONEMES.each do |phoneme, _color, regexp, replace|
      prepared_word = prepared_word.gsub(regexp, replace) if word_contains_phoneme(phonemized_word, phoneme)
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

  def prepare(text) # rubocop:disable Metrics/MethodLength
    # split text into words, separate punctuation from words
    # the sentence "c'est un exemple. Comme un autre" becomes ["c", "'"", " ", "est", " ", "un", " ", "exemple", ".", " ", "Comme", " ", "un", " ", "autre"]
    words = text.split(/(\W)/).reject(&:empty?)

    # get phonemized words from Redis
    phonemized_pairs = words.map do |word|
      case word
      when /\W/
        [word, nil]
      else
        [word, redis_client.get(word.downcase)]
      end
    end

    prepared_text = phonemized_pairs.map { |word, phonemized_word| prepare_word(word, phonemized_word) }.join
    # remove spaces before punctuation

    prepared_text.gsub("\n", '<br>')
  end

  def write_all_keys_not_in_redis_to_file(filename_src, filename_dest) # rubocop:disable Metrics/AbcSize
    # list all words in the file
    all_words = File.read(filename_src).split.map(&:downcase)

    # list all words in redis
    redis_words = redis_client.keys

    # list all words not in redis
    words_not_in_redis = all_words - redis_words

    words_not_in_redis.reject! { |word| word.start_with?("l'") || word.start_with?("d'") }

    words_not_in_redis = words_not_in_redis.map { |word| word.gsub('\-', '-') }.uniq.sort.reverse

    # write all words not in redis to file
    File.open(filename_dest, 'w') do |file|
      words_not_in_redis.each do |word|
        file.puts(word)
      end
    end
  end

  def write_all_redis_keys_and_value_in_file(filename)
    File.open(filename, 'w') do |file|
      redis_client.keys.each do |word|
        file.puts("#{word}: #{redis_client.get(word)}")
      end
    end
  end
end
