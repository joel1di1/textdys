# frozen_string_literal: true

require 'rails_helper'
require_relative '../../app/services/word_preparer'

def expect_prep(word, expected)
  expect(WordPreparer.new.prepare(word)).to eq(expected)
end

RSpec.describe WordPreparer do
  describe '#prepare_word' do
    it { expect_prep('a', 'a') }
    it { expect_prep('lointaine', 'lo<span class="green">in</span>t<span class="purple">ai</span>ne') }
    it { expect_prep('on', '<span class="brown">on</span>') }
    it { expect_prep('boîte', 'b<span class="black">oî</span>te') }
    it { expect_prep('disparaître', 'dispar<span class="purple">aî</span>tre') }
    it { expect_prep('intéresse', '<span class="green">in</span>téresse') }
    it { expect_prep('connaît', 'conn<span class="purple">aî</span>t') }
    it { expect_prep('onze', '<span class="brown">on</span>ze') }
    it { expect_prep('rouillé', 'r<span class="red">ou</span>illé') }
    it { expect_prep('impression', '<span class="green">im</span>pressi<span class="brown">on</span>') }
    it { expect_prep("j'ai", "j'ai") }
    it { expect_prep("aujourd'hui", '<span class="pink">au</span>j<span class="red">ou</span>rd\'hui') }
    it { expect_prep('où', '<span class="red">où</span>') }
    it { expect_prep('apparemment', 'apparemm<span class="orange">en</span>t') }
    it { expect_prep('souterrains', 's<span class="red">ou</span>terr<span class="green"><span class="purple">ai</span>n</span>s') }
    it { expect_prep('terrains', 'terr<span class="green"><span class="purple">ai</span>n</span>s') }
    # it { expect_prep('enfourchent', "<span class=\"orange\">en</span>f<span class=\"red\">ou</span>rchent") }
    it { expect_prep('insinuent', '<span class="green">in</span>sinuent') }
    # it { expect_prep('rangent', "r<span class=\"orange\">an</span>gent") }
    # it { expect_prep('entrent', "<span class=\"orange\">en</span>trent") }
    it { expect_prep('prononcé', 'pron<span class="brown">on</span>cé') }
    it { expect_prep('ronchonne', "r<span class=\"brown\">on</span>chonne") }
    it { expect_prep('dégoûtant', "dég<span class=\"red\">oû</span>t<span class=\"orange\">an</span>t") }
  end
end
