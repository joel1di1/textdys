import unittest
from text_to_dys import process_text_to_dys

class TestTextToDys(unittest.TestCase):

    def assertTextTransformed(self, input_text, expected_output):
        result = process_text_to_dys(input_text)
        self.assertEqual(result, expected_output)

    def test_highlight_tool_words(self):
        self.assertTextTransformed('et', '<span class="tool-word">et</span>')
        self.assertTextTransformed('Dans ce que je suis, ra est avec tata',
                                   '<span class="tool-word">Dans</span> ce <span class="tool-word">que</span> je suis, ra <span class="tool-word">est</span> <span class="tool-word">avec</span> tata')

    def test_phoneme_highlighting(self):
        self.assertTextTransformed('rouge', 'r<span class="red">ou</span>ge')

        self.assertTextTransformed('noir', 'n<span class="black">oi</span>r')

        self.assertTextTransformed('marron', 'marr<span class="brown">on</span>')
        self.assertTextTransformed('tombe', 't<span class="brown">om</span>be')

        self.assertTextTransformed('orange', 'or<span class="orange">an</span>ge')
        self.assertTextTransformed('Empire', '<span class="orange">Em</span>pire')
        self.assertTextTransformed('vendus', 'v<span class="orange">en</span>dus')
        self.assertTextTransformed('Ambulance', '<span class="orange">Am</span>bul<span class="orange">an</span>ce')

        self.assertTextTransformed('aide', '<span class="purple">ai</span>de')
        self.assertTextTransformed('était', 'ét<span class="purple">ai</span>t')

        self.assertTextTransformed('eau', '<span class="pink">eau</span>')
        self.assertTextTransformed('bleu', 'bl<span class="blue">eu</span>')
        self.assertTextTransformed('sapin', 'sap<span class="green">in</span>')

    # Additional tests can be added here

if __name__ == '__main__':

    unittest.main()
