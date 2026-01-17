# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Includes do
  include Minicrest::Assertions

  describe 'with strings' do
    describe '#matches?' do
      it 'matches when string contains single substring' do
        assert includes('hello').matches?('hello world')
      end

      it 'matches when string contains multiple substrings' do
        assert includes('hello', 'world').matches?('hello world')
      end

      it 'does not match when string missing substring' do
        refute includes('goodbye').matches?('hello world')
      end

      it 'does not match when string missing any substring' do
        refute includes('hello', 'goodbye').matches?('hello world')
      end
    end

    describe '#failure_message' do
      it 'lists missing substrings' do
        assert_equal includes('goodbye', 'farewell').failure_message('hello world'), <<~MSG.chomp
          expected "hello world" to include "goodbye", "farewell"
          missing: "goodbye", "farewell"
        MSG
      end

      it 'shows only missing items when some present' do
        assert_equal includes('hello', 'goodbye').failure_message('hello world'), <<~MSG.chomp
          expected "hello world" to include "hello", "goodbye"
          missing: "goodbye"
        MSG
      end
    end
  end

  describe 'with arrays' do
    describe '#matches?' do
      it 'matches when array contains single element' do
        assert includes(2).matches?([1, 2, 3])
      end

      it 'matches when array contains multiple elements' do
        assert includes(1, 3).matches?([1, 2, 3])
      end

      it 'does not match when array missing element' do
        refute includes(5).matches?([1, 2, 3])
      end

      it 'does not match when array missing any element' do
        refute includes(1, 5).matches?([1, 2, 3])
      end
    end

    describe '#failure_message' do
      it 'lists missing elements' do
        assert_equal includes(5, 6).failure_message([1, 2, 3]), <<~MSG.chomp
          expected [1, 2, 3] to include 5, 6
          missing: 5, 6
        MSG
      end
    end
  end

  describe 'with hashes' do
    describe '#matches?' do
      it 'matches when hash contains single key-value pair' do
        assert includes(a: 1).matches?({ a: 1, b: 2 })
      end

      it 'matches when hash contains multiple key-value pairs' do
        assert includes(a: 1, c: 3).matches?({ a: 1, b: 2, c: 3 })
      end

      it 'does not match when hash missing key' do
        refute includes(d: 4).matches?({ a: 1, b: 2 })
      end

      it 'does not match when hash has key but wrong value' do
        refute includes(a: 2).matches?({ a: 1, b: 2 })
      end
    end

    describe '#failure_message' do
      it 'lists missing pairs' do
        assert_equal includes(c: 3, d: 4).failure_message({ a: 1, b: 2 }), <<~MSG.chomp
          expected {a: 1, b: 2} to include {c: 3, d: 4}
          missing: {c: 3, d: 4}
        MSG
      end
    end
  end

  describe '#description' do
    it 'describes included items for strings' do
      assert_equal 'includes "hello", "world"', includes('hello', 'world').description
    end

    it 'describes included items for arrays' do
      assert_equal 'includes 1, 2', includes(1, 2).description
    end

    it 'describes included pairs for hashes' do
      assert_equal 'includes {a: 1}', includes(a: 1).description
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected inclusion' do
      assert_equal includes('hello').negated_failure_message('hello world'), <<~MSG.chomp
        expected "hello world" not to include "hello", but it did
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(includes('goodbye')).matches?('hello world')
      refute never(includes('hello')).matches?('hello world')
    end

    it 'works with & operator' do
      assert (includes('hello') & includes('world')).matches?('hello world')
      refute (includes('hello') & includes('goodbye')).matches?('hello world')
    end
  end
end
