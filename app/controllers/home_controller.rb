class HomeController < ApplicationController
  def index
    # This will render the form
  end

  def transform_text
    input_text = params[:text]
    words = input_text.split
    transformed_words = words.map { |word| transform_word(word) }
    @transformed_text = transformed_words.join(' ')

    render :index
  end

  private

  def transform_word(word)
    phonemized_word = $redis.get(word)
    # Here you will add logic to transform the word for dyslexic readers
    # For now, we just return the phonemized word or the original word if not found in Redis
    phonemized_word || word
  end
end
