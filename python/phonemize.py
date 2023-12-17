from phonemizer import phonemize
import sys

# takes a string as argument of the program
if len(sys.argv) > 1:
	text = sys.argv[1]
	# Phonemizing the text using the eSpeak backend and specifying French
	phonemes = phonemize(text, language='fr-fr', backend='espeak')

	print(phonemes)
