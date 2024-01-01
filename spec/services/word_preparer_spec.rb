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
  end
end
