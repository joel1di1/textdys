import re
from phonemizer import phonemize

TOOL_WORDS = ['et', 'que', 'qui', 'est', 'sont', 'avec', 'pour', 'dans',
              'mais', 'alors', 'aussi', 'chez']
SPECIAL_PHONEMES = [
                    ['u', 'red', r'(ou)'],
                    ['wa', 'black', r'(oi)'],
                    ['ɔ̃', 'brown', r'(on|om)'],
                    ['ɑ̃', 'orange', r'(an|em|en|am)'],
                    ['ɛ', 'purple', r'(ai|ei)'],
                    ['o', 'pink', r'(eau|au)'],
                    ['ø', 'blue', r'(eu)'],
                    ['œ', 'blue', r'(eu)'],
                    ['ɛ̃', 'green', r'(in|ain|ein)'],
]

def process_text_to_dys(text):
    words = text.split()
    highlighted_words = [highlight_word(word) for word in words]
    return ' '.join(highlighted_words)

def highlight_word(word):
    if word.lower() in TOOL_WORDS:
        return f'<span class="tool-word">{word}</span>'
    else:
        word_phonemes = phonemize(word, language='fr-fr', backend='espeak')
        # print(f'phonemes for word {word}: {word_phonemes}')
        # for each special phoneme, if the word contains it, highlight the corresponding part of the word
        for specials in SPECIAL_PHONEMES:
            phoneme = specials[0]
            color = specials[1]
            regexp = specials[2]
            # print(f'checking phoneme {phoneme} in word {word}, phonemes {word_phonemes}')
            if phoneme in word_phonemes:
                # print(f'word {word} contains phoneme {phoneme}')
                # in the original word, replace the regexp by the regexp with the span
                # regex is non-case sensitive
                word = re.sub(regexp, rf'<span class="{color}">\1</span>', word, flags=re.IGNORECASE)

    return word

def phonemize_text(text):
    words = text.split()
    phonemized_words = [phonemize(word, language='fr-fr', backend='espeak') for word in words]
    return ' '.join(phonemized_words)
