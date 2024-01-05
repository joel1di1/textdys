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
    ['ɛ̃', 'green', /((a|e)?(i|y)[nm](?!e|a|u|i|o))/i, '<span class="green">\1</span>'],
    ['ɛ', 'purple', /((a|e)[iî])/i, '<span class="purple">\1</span>'],
    ['o', 'pink', /(eau|au)/i, '<span class="pink">\1</span>'],
    ['ø', 'blue', /(eu)/i, '<span class="blue">\1</span>'],
    ['œ', 'blue', /(eu)/i, '<span class="blue">\1</span>']
  ].freeze

  FLOW_REPLACEMENTS = {
    '$$chapitre$$' => '<div class="break-after-page"></div>'
  }

  CACHE = {} # rubocop:disable Style/MutableConstant

  File.foreach('all_redis.txt') do |line|
    word, phonemized_word = line.split(':').map(&:strip)

    CACHE[word] = phonemized_word
  end

  def redis_client
    @redis_client ||= Redis.new
  end

  def colorize_phoneme(word, phonemized_word, phoneme, regexp, replace)
    nb_to_replace = word_contains_phoneme(phonemized_word, phoneme)

    return word if nb_to_replace.zero?

    to_be_replaced = word
    left = ''


    nb_to_replace.times do
      # debugger
      index = to_be_replaced.index(regexp)
      break if index.nil?
      left += to_be_replaced[0...index] + to_be_replaced[regexp].gsub(regexp, replace)
      to_be_replaced = to_be_replaced[(index + to_be_replaced[regexp].size)..]
    end

    left + to_be_replaced
  end

  def prepare_word(word, phonemized_word)
    return word if word.match?(/^\W+$/)
    return word if phonemized_word.blank?

    return "<span class=\"tool-word\">#{word}</span>" if TOOL_WORDS.include?(word.downcase)

    prepared_word = word
    SPECIAL_PHONEMES.each do |phoneme, _color, regexp, replace|
      prepared_word = colorize_phoneme(prepared_word, phonemized_word, phoneme, regexp, replace)
    end

    prepared_word
  end

  def word_contains_phoneme(word_phonemes, phoneme) # rubocop:disable Metrics/AbcSize
    word_phonemes_chars = word_phonemes.chars
    phoneme_chars = phoneme.chars

    nb_contains = 0

    (word_phonemes_chars.length - phoneme_chars.length + 1).times do |i|
      phoneme_chars.length.times do |j|
        break if word_phonemes_chars[i + j] != phoneme_chars[j]

        if j == phoneme_chars.length - 1 &&
           (word_phonemes_chars.length <= i + j + 1 || word_phonemes_chars[i + j + 1] != CHAR_RELOU)
          nb_contains += 1
        end
      end
    end
    nb_contains
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

    prepared_text.gsub!("\n", '<br>')

    # replace flow words
    FLOW_REPLACEMENTS.each do |flow_word, replacement|
      prepared_text.gsub!(flow_word, replacement)
    end


    # for all , ; : . ? ! ) }, replace previous space with non-breaking space
    prepared_text.gsub!(/ ([,;:»\-–\.\?!)\}])/) { |_match| "&nbsp;#{Regexp.last_match(1)}" }

    prepared_text.gsub!(/([\(\{\-–»]) /) { |_match| "#{Regexp.last_match(1)}&nbsp;" }

    prepared_text
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

  def check_redis_keys()

    # read all_redis_check and list all keys in a Set
    all_words = File.read('all_redis_check.txt').split("\n").map { |line| line.split(':').first }.to_set

    # in a map
    words_to_rechecks = CACHE.entries.reject { |word, _phonemized_word| all_words.include?(word) }.to_h

    progressbar = ProgressBar.create(:format => '%a <%B> %p%% %e')
    progressbar.total = words_to_rechecks.size

    batch_size = 100
    # append to file
    File.open('all_redis_check.txt', 'a') do |file|
      words_to_rechecks.each_slice(batch_size) do |slice|
        # all keys 
        keys = slice.map { |word, _phonemized_word| word }

        # all values
        values = slice.map { |_word, phonemized_word| phonemized_word }

        phonemized_words = `python3 #{Rails.root}/python/text_to_dys.py "#{keys.join("\n")}"`

        phonemized_words_split = phonemized_words.split("\n")
        if phonemized_words_split.length != keys.length
          puts "Error for:"
          (0...keys.length).each do |index|
            puts "#{keys[index]}: #{phonemized_words_split[index]}"
          end
          return
        end

        phonemized_words_split.each_with_index do |phonemized_word, index|
          if phonemized_word != values[index]
            # puts "Error for #{keys[index]}: #{values[index]}  != #{phonemized_word} (cache-new)"
          end

          file.puts("#{keys[index]}: #{phonemized_word}")
        end

        # increment progress bar if neccessary, based on words_to_rechecks size
        progressbar.progress += slice.length
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
