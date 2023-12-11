import unittest
from text_to_dys import process_text_to_dys

class TestTextToDys(unittest.TestCase):

    def assertTextTransformed(self, input_text, expected_output):
        result = process_text_to_dys(input_text)
        self.assertEqual(result, expected_output)

    def test_highlight_tool_words(self):
        1+1
        self.assertTextTransformed('et', '<span class="tool-word">et</span>')
        self.assertTextTransformed('Dans ce que je suis, ra est avec tata',
                                   '<span class="tool-word">Dans</span> ce <span class="tool-word">que</span> je suis, ra <span class="tool-word">est</span> <span class="tool-word">avec</span> tata')

    def test_phoneme_highlighting_ou(self):
        self.assertTextTransformed('rouge', 'r<span class="red">ou</span>ge')

    def test_phoneme_highlighting_oi(self):
        self.assertTextTransformed('noir', 'n<span class="black">oi</span>r')

    def test_phoneme_highlighting_on(self):
        self.assertTextTransformed('marron', 'marr<span class="brown">on</span>')
        self.assertTextTransformed('tombe', 't<span class="brown">om</span>be')

    def test_phoneme_highlighting_an(self):
        self.assertTextTransformed('orange', 'or<span class="orange">an</span>ge')
        self.assertTextTransformed('Empire', '<span class="orange">Em</span>pire')
        self.assertTextTransformed('vendus', 'v<span class="orange">en</span>dus')
        self.assertTextTransformed('Ambulance', '<span class="orange">Am</span>bul<span class="orange">an</span>ce')

    def test_phoneme_highlighting_ai(self):
        self.assertTextTransformed('aide', '<span class="purple">ai</span>de')
        self.assertTextTransformed('était', 'ét<span class="purple">ai</span>t')

    def test_phoneme_highlighting_au(self):
        self.assertTextTransformed('eau', '<span class="pink">eau</span>')
        self.assertTextTransformed('bleu', 'bl<span class="blue">eu</span>')

    def test_phoneme_highlighting_in(self):
        self.assertTextTransformed('sapin', 'sap<span class="green">in</span>')
        self.assertTextTransformed('teinte', 't<span class="green">ein</span>te')

    def test_phoneme_highlighting_lentement(self):
        self.assertTextTransformed('lentement', 'l<span class="orange">en</span>tem<span class="orange">en</span>t')

    def test_phoneme_highlighting_joyeusement(self):
        self.assertTextTransformed('joyeusement', 'joy<span class="blue">eu</span>sem<span class="orange">en</span>t')

    def test_phoneme_highlighting_nommée(self):
        self.assertTextTransformed('nommée', 'nommée')

    def test_phoneme_highlighting_remplissaient(self):
        self.assertTextTransformed('remplissaient', 'r<span class="orange">em</span>pliss<span class="purple">ai</span>ent')

    def test_phoneme_highlighting_lointaine(self):
        self.assertTextTransformed('lointaine', 'lo<span class="green">in</span>t<span class="purple">ai</span>ne')


if __name__ == '__main__':

    unittest.main()
