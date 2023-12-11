import re
import sys
import unicodedata
from phonemizer import phonemize

TOOL_WORDS = ['et', 'que', 'qui', 'est', 'sont', 'avec', 'pour', 'dans',
              'mais', 'alors', 'aussi', 'chez']

CHAR_RELOU = list('ɛ̃')[1]

regexp_an_not_followed_by_e = r'(?<!e)an'

SPECIAL_PHONEMES = [
                    ['ɑ̃', 'orange', r'(?<!ai)(an|em|en|am)(?!e|a)', rf'<span class="orange">\1</span>'],
                    ['u', 'red', r'(ou)', rf'<span class="red">\1</span>'],
                    ['wa', 'black', r'(oi)', rf'<span class="black">\1</span>'],
                    ['ɔ̃', 'brown', r'(on|om)', rf'<span class="brown">\1</span>'],
                    ['ɛ̃', 'green', r'((a|e)?in)', rf'<span class="green">\1</span>'],
                    ['ɛ', 'purple', r'(ai|ei)', rf'<span class="purple">\1</span>'],
                    ['o', 'pink', r'(eau|au)', rf'<span class="pink">\1</span>'],
                    ['ø', 'blue', r'(eu)', rf'<span class="blue">\1</span>'],
                    ['œ', 'blue', r'(eu)', rf'<span class="blue">\1</span>'],
]

def process_text_to_dys(text):
    # get each line
    lines = text.split('\n')
    # for each line

    highlight_text = ''
    for i in range(len(lines)):
        # get all the words of the line
        words = lines[i].split()
        # highlight each word
        highlighted_words = [highlight_word(word) for word in words]
        # join the words back together
        highlighted_line = ' '.join(highlighted_words)
        # add the line to the text surrounded by a p
        highlight_text += f'<p>{highlighted_line}</p>'

    return highlight_text

def word_contains_phoneme(word_phonemes, phoneme):
    # print(f'checking if word {word_phonemes} contains phoneme {phoneme}')
    word_phonemes_chars = list(word_phonemes)
    phoneme_chars = list(phoneme)
    # print(f'\tchecking if word {word_phonemes_chars} contains phoneme {phoneme_chars}')
    # for each position in the word, check if the array matches
    for i in range(len(word_phonemes_chars)-len(phoneme_chars)+1):
        for j in range(len(phoneme_chars)):
            # print(f'checking word {word_phonemes_chars} at position {i+j} with phoneme {phoneme_chars} at position {j}')
            if word_phonemes_chars[i+j] != phoneme_chars[j]:
                break
            if j == len(phoneme_chars)-1 and (len(word_phonemes_chars) <= i+j+1 or word_phonemes_chars[i+j+1] != CHAR_RELOU):
                return True


def highlight_word(word):
    if word.lower() in TOOL_WORDS:
        return f'<span class="tool-word">{word}</span>'
    else:
        word_phonemes = phonemize(word, language='fr-fr', backend='espeak')
        word_phonemes = unicodedata.normalize('NFC', word_phonemes).strip()
        # for each special phoneme, if the word contains it, highlight the corresponding part of the word
        for specials in SPECIAL_PHONEMES:
            phoneme = specials[0]
            color = specials[1]
            regexp = specials[2]
            replace = specials[3]
            # print(f'checking phoneme {phoneme} in word {word}, phonemes {word_phonemes}')
            if word_contains_phoneme(word_phonemes, phoneme):
                # print(f'word {word} contains phoneme {phoneme}')
                # in the original word, replace the regexp by the regexp with the span
                # regex is non-case sensitive
                word = re.sub(regexp, replace, word, flags=re.IGNORECASE)

    return word

def phonemize_text(text):
    words = text.split()
    phonemized_words = [phonemize(word.strip, language='fr-fr', backend='espeak') for word in words]
    return ' '.join(phonemized_words)




def main():
    text = ' '.join(sys.argv[1:])
    print(phonemize(text, language='fr-fr', backend='espeak'))

if __name__ == "__main__":
    main()
