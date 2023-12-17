# frozen_string_literal: true

RSpec.describe WordPreparer do
  let(:word_preparer) { WordPreparer.new }

  # Write your tests here
  describe '#prepare' do
    it { expect(word_preparer.prepare('ceci')).to eq('ceci') }
    it { expect(word_preparer.prepare('et')).to eq('<span class="tool-word">et</span>') }
    it { expect(word_preparer.prepare('Dans ce que je suis, ra est avec tata')).to eq('<span class="tool-word">Dans</span> ce <span class="tool-word">que</span> je suis, ra <span class="tool-word">est</span> <span class="tool-word">avec</span> tata') }
    it { expect(word_preparer.prepare('rouge')).to eq('r<span class="red">ou</span>ge') }
    it { expect(word_preparer.prepare('noir')).to eq('n<span class="black">oi</span>r') }
    it { expect(word_preparer.prepare('marron')).to eq('marr<span class="brown">on</span>') }
    it { expect(word_preparer.prepare('tombe')).to eq('t<span class="brown">om</span>be') }
    it { expect(word_preparer.prepare('orange')).to eq('or<span class="orange">an</span>ge') }
    it { expect(word_preparer.prepare('Empire')).to eq('<span class="orange">Em</span>pire') }
    it { expect(word_preparer.prepare('vendus')).to eq('v<span class="orange">en</span>dus') }
    it { expect(word_preparer.prepare('Ambulance')).to eq('<span class="orange">Am</span>bul<span class="orange">an</span>ce') }
    it { expect(word_preparer.prepare('aide')).to eq('<span class="purple">ai</span>de') }
    it { expect(word_preparer.prepare('était')).to eq('ét<span class="purple">ai</span>t') }
    it { expect(word_preparer.prepare('eau')).to eq('<span class="pink">eau</span>') }
    it { expect(word_preparer.prepare('bleu')).to eq('bl<span class="blue">eu</span>') }
    it { expect(word_preparer.prepare('sapin')).to eq('sap<span class="green">in</span>') }
    it { expect(word_preparer.prepare('teinte')).to eq('t<span class="green">ein</span>te') }
    it { expect(word_preparer.prepare('lentement')).to eq('l<span class="orange">en</span>tem<span class="orange">en</span>t') }
    it { expect(word_preparer.prepare('joyeusement')).to eq('joy<span class="blue">eu</span>sem<span class="orange">en</span>t') }
    it { expect(word_preparer.prepare('nommée')).to eq('nommée') }
    it { expect(word_preparer.prepare('remplissaient')).to eq('r<span class="orange">em</span>pliss<span class="purple">ai</span>ent') }
    it { expect(word_preparer.prepare('lointaine')).to eq('lo<span class="green">in</span>t<span class="purple">ai</span>ne') }
  end

  describe '#word_contains_phoneme' do
    it 'returns true when word contains the phoneme' do
      expect(word_preparer.word_contains_phoneme('tɛ̃t', 'ɛ̃')).to be(true)
    end

    it 'returns false when word does not contain the phoneme' do
      expect(word_preparer.word_contains_phoneme('tɛ̃t', 'ɛ')).to be(false)
    end

    it 'returns false when phoneme is longer than word' do
      expect(word_preparer.word_contains_phoneme('ɛ̃', 'tɛ̃t')).to be(false)
    end
  end
end
