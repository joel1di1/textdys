import re
import unicodedata
from phonemizer import phonemize

TOOL_WORDS = ['et', 'que', 'qui', 'est', 'sont', 'avec', 'pour', 'dans',
              'mais', 'alors', 'aussi', 'chez']
SPECIAL_PHONEMES = [
                    ['u', 'red', r'(.*)(ou)(.*)'],
                    ['wa', 'black', r'(.*)(oi)(.*)'],
                    ['ɔ̃', 'brown', r'(.*)(on|om)(.*)'],
                    ['ɑ̃', 'orange', r'(.*)(an|em|en|am)([^nm].*)?$'],
                    ['ɛ̃', 'green', r'(.*)(ain|ein)(.*)'],
                    ['ɛ', 'purple', r'(.*)(ai|ei)(.*)'],
                    ['o', 'pink', r'(.*)(eau|au)(.*)'],
                    ['ø', 'blue', r'(.*)(eu)(.*)'],
                    ['œ', 'blue', r'(.*)(eu)(.*)'],
]

def process_text_to_dys(text):
    words = text.split()
    highlighted_words = [highlight_word(word) for word in words]
    return ' '.join(highlighted_words)

def word_contains_phoneme(word_phonemes, phoneme):
    phoneme_chars = list(phoneme)
    word_phonemes_chars = list(word_phonemes)
    # for each position in the word, check if the array matches
    for i in range(len(word_phonemes_chars)-len(phoneme_chars)+1):
        for j in range(len(phoneme_chars)):
            print(f'checking word {word_phonemes_chars} at position {i+j} with phoneme {phoneme_chars} at position {j}')
            if word_phonemes_chars[i+j] != phoneme_chars[j]:
                break
            else:
                return True


def highlight_word(word):
    if word.lower() in TOOL_WORDS:
        return f'<span class="tool-word">{word}</span>'
    else:
        word_phonemes = phonemize(word, language='fr-fr', backend='espeak')
        word_phonemes = unicodedata.normalize('NFC', word_phonemes)
        print(f'phonemes for word {word}: {word_phonemes}, {list(word_phonemes)}, {list("ɛ̃")}')
        # for each special phoneme, if the word contains it, highlight the corresponding part of the word
        for specials in SPECIAL_PHONEMES:
            phoneme = specials[0]
            color = specials[1]
            regexp = specials[2]
            print(f'checking phoneme {phoneme} in word {word}, phonemes {word_phonemes}')
            if word_contains_phoneme(word_phonemes, phoneme):
                print(f'word {word} contains phoneme {phoneme}')
                # in the original word, replace the regexp by the regexp with the span
                # regex is non-case sensitive
                word = re.sub(regexp, rf'\1<span class="{color}">\2</span>\3', word, flags=re.IGNORECASE)

    return word

def phonemize_text(text):
    words = text.split()
    phonemized_words = [phonemize(word, language='fr-fr', backend='espeak') for word in words]
    return ' '.join(phonemized_words)
