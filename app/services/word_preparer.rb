# frozen_string_literal: true

class WordPreparer
  TOOL_WORDS = %w[et que qui est sont avec pour dans
                  mais alors aussi chez].freeze

  CHAR_RELOU = 'ɛ̃'.chars[1]

  SPECIAL_PHONEMES = [
    ['ɑ̃', 'orange', /(?<!ai)(an|em|en|am)(?!(e|a)|ment)/i, '<span class="orange">\1</span>'],
    ['u', 'red', /(o[uùû])/i, '<span class="red">\1</span>'],
    ['wa', 'black', /(o[iî])/i, '<span class="black">\1</span>'],
    ['ɔ̃', 'brown', /(on|om)(?!e|a|u|i|o|n)/i, '<span class="brown">\1</span>'],
    ['ɛ̃', 'green', /((a|e)?i[nm](?!e|a|u|i|o))/i, '<span class="green">\1</span>'],
    ['ɛ', 'purple', /((a|e)[iî])/i, '<span class="purple">\1</span>'],
    ['o', 'pink', /(eau|au)/i, '<span class="pink">\1</span>'],
    ['ø', 'blue', /(eu)/i, '<span class="blue">\1</span>'],
    ['œ', 'blue', /(eu)/i, '<span class="blue">\1</span>']
  ].freeze

  CACHE = {} # rubocop:disable Style/MutableConstant

  File.foreach('all_redis.txt') do |line|
    word, phonemized_word = line.split(':').map(&:strip)

    CACHE[word] = phonemized_word
  end

  def redis_client
    @redis_client ||= Redis.new
  end

  def prepare_word(word, phonemized_word)
    return word if word.match?(/^\W+$/)
    return word if phonemized_word.blank?

    return "<span class=\"tool-word\">#{word}</span>" if TOOL_WORDS.include?(word.downcase)

    prepared_word = word
    SPECIAL_PHONEMES.each do |phoneme, _color, regexp, replace|
      prepared_word = prepared_word.gsub(regexp, replace) if word_contains_phoneme(phonemized_word, phoneme)
    end

    prepared_word
  end

  def word_contains_phoneme(word_phonemes, phoneme) # rubocop:disable Metrics/AbcSize
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

  def cache
    return @cache if @cache

    @cache = {}
    File.foreach('all_redis.txt') do |line|
      word, phonemized_word = line.split(':').map(&:strip)

      cache[word] = phonemized_word
    end
    @cache
  end

  def get_phonemized_word(word)
    CACHE[word.downcase]
  end

  def prepare(text)
    # split text into words, separate punctuation from words
    # the sentence "c'est un exemple. Comme un autre"
    # becomes ["c", "'"", " ", "est", " ", "un", " ", "exemple", ".", " ", "Comme", " ", "un", " ", "autre"]
    words = text.split(/(\b)/).reject(&:empty?)

    # get phonemized words from Redis
    phonemized_pairs = words.map do |word|
      case word
      when /^\W+$/
        [word, nil]
      else
        [word, get_phonemized_word(word)]
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
      redis_client.each_keys do |word|
        file.puts("#{word}: #{redis_client.get(word)}")
      end
    end
  end
end

# def read_file_and_fill_memory_hash(filename)
#   cache = {}
#   File.foreach(filename) do |line|
#     word, phonemized_word = line.split(':').map(&:strip)

#     cache[word] = phonemized_word
#   end
# end
