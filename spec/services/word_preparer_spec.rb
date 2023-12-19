# frozen_string_literal: true

RSpec.describe WordPreparer do
  let(:word_preparer) { WordPreparer.new }

  before do
    redis_client = Redis.new

    redis_client.set('ceci', 'səsi')
    redis_client.set('et', 'e')
    redis_client.set('dans', 'dɑ̃')
    redis_client.set('rouge', 'ʁuʒ')
    redis_client.set('noir', 'nwaʁ')
    redis_client.set('marron', 'maʁɔ̃')
    redis_client.set('tombe', 'tɔ̃b')
    redis_client.set('orange', 'ɔʁɑ̃ʒ')
    redis_client.set('empire', 'ɑ̃piʁ')
    redis_client.set('vendus', 'vɑ̃dy')
    redis_client.set('ambulance', 'ɑ̃bylɑ̃s')
    redis_client.set('aide', 'ɛd')
    redis_client.set('était', 'etɛt')
    redis_client.set('eau', 'o')
    redis_client.set('bleu', 'blø')
    redis_client.set('sapin', 'sapɛ̃')
    redis_client.set('teinte', 'tɛ̃t')
    redis_client.set('lentement', 'lɑ̃tmɑ̃')
    redis_client.set('joyeusement', 'ʒwajøzmɑ̃')
    redis_client.set('nommée', 'nɔme')
    redis_client.set('remplissaient', 'ʁɑ̃plisɛ')
    redis_client.set('lointaine', 'lwɛ̃tɛn')
    redis_client.set('ensemble', 'ɑ̃sɑ̃bl')
  end

  def ewp(text, expected)
    expect(word_preparer.prepare(text)).to eq(expected)
  end

  # rubocop:disable RSpec/NoExpectationExample
  describe '#prepare' do
    it { ewp('Dans ce que je suis, ra est avec tata', '<span class="tool-word">Dans</span> ce <span class="tool-word">que</span> je suis, ra <span class="tool-word">est</span> <span class="tool-word">avec</span> tata') } # rubocop:disable Layout/LineLength
    it { ewp('ceci', 'ceci') }
    it { ewp('et', '<span class="tool-word">et</span>') }
    it { ewp('rouge', 'r<span class="red">ou</span>ge') }
    it { ewp('noir', 'n<span class="black">oi</span>r') }
    it { ewp('marron', 'marr<span class="brown">on</span>') }
    it { ewp('tombe', 't<span class="brown">om</span>be') }
    it { ewp('orange', 'or<span class="orange">an</span>ge') }
    it { ewp('Empire', '<span class="orange">Em</span>pire') }
    it { ewp('vendus', 'v<span class="orange">en</span>dus') }
    it { ewp('Ambulance', '<span class="orange">Am</span>bul<span class="orange">an</span>ce') }
    it { ewp('aide', '<span class="purple">ai</span>de') }
    it { ewp('était', 'ét<span class="purple">ai</span>t') }
    it { ewp('eau', '<span class="pink">eau</span>') }
    it { ewp('bleu', 'bl<span class="blue">eu</span>') }
    it { ewp('sapin', 'sap<span class="green">in</span>') }
    it { ewp('teinte', 't<span class="green">ein</span>te') }
    it { ewp('lentement', 'l<span class="orange">en</span>tem<span class="orange">en</span>t') }
    it { ewp('joyeusement', 'joy<span class="blue">eu</span>sem<span class="orange">en</span>t') }
    it { ewp('nommée', 'nommée') }
    it { ewp('remplissaient', 'r<span class="orange">em</span>pliss<span class="purple">ai</span>ent') }
    it { ewp('lointaine', 'lo<span class="green">in</span>t<span class="purple">ai</span>ne') }
    it { ewp('ensemble', '<span class="orange">en</span>s<span class="orange">em</span>ble') }

    it { ewp('aide.', '<span class="purple">ai</span>de.') }
    it { ewp("ce\ntext\nsur\nlignes", 'ce<br>text<br>sur<br>lignes') }
  end
  # rubocop:enable RSpec/NoExpectationExample

  describe '#word_contains_phoneme' do
    it { expect(word_preparer.word_contains_phoneme('tɛ̃t', 'ɛ̃')).to be(true) }
    it { expect(word_preparer.word_contains_phoneme('tɛ̃t', 'ɛ')).to be(false) }
    it { expect(word_preparer.word_contains_phoneme('ɛ̃', 'tɛ̃t')).to be(false) }
    it { expect(word_preparer.word_contains_phoneme('ɑ̃piʁ', 'ɑ̃')).to be(true) }
  end
end
