# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::HasSize do
  include Minicrest::Assertions

  describe '#matches?' do
    describe 'with integer argument' do
      it 'matches string with correct length' do
        assert has_size(5).matches?('hello')
      end

      it 'does not match string with wrong length' do
        refute has_size(3).matches?('hello')
      end

      it 'matches array with correct size' do
        assert has_size(3).matches?([1, 2, 3])
      end

      it 'does not match array with wrong size' do
        refute has_size(5).matches?([1, 2, 3])
      end

      it 'matches hash with correct size' do
        assert has_size(2).matches?({ a: 1, b: 2 })
      end

      it 'does not match hash with wrong size' do
        refute has_size(3).matches?({ a: 1, b: 2 })
      end

      it 'matches empty collections with size 0' do
        assert has_size(0).matches?('')
        assert has_size(0).matches?([])
        assert has_size(0).matches?({})
      end
    end

    describe 'with matcher argument' do
      it 'matches when size satisfies matcher' do
        assert has_size(equals(5)).matches?('hello')
      end

      it 'does not match when size does not satisfy matcher' do
        refute has_size(equals(3)).matches?('hello')
      end

      it 'works with never matcher' do
        assert has_size(never(equals(0))).matches?('hello')
        refute has_size(never(equals(5))).matches?('hello')
      end

      it 'works with combined matchers' do
        # Size is greater than 2 AND less than 10
        matcher = has_size(equals(3) | equals(4) | equals(5))

        assert matcher.matches?([1, 2, 3])
        assert matcher.matches?([1, 2, 3, 4])
        assert matcher.matches?([1, 2, 3, 4, 5])
        refute matcher.matches?([1, 2])
        refute matcher.matches?([1, 2, 3, 4, 5, 6])
      end
    end
  end

  describe '#description' do
    it 'describes expected size for integer' do
      assert_equal 'has size 5', has_size(5).description
    end

    it 'describes expected size for matcher' do
      assert_equal 'has size equal to 3', has_size(equals(3)).description
    end

    it 'describes complex matcher' do
      assert_equal 'has size (equal to 3 or equal to 4)', has_size(equals(3) | equals(4)).description
    end
  end

  describe '#failure_message' do
    it 'explains size mismatch for integer' do
      assert_equal has_size(3).failure_message('hello'), <<~MSG.chomp
        expected "hello" to have size 3, but had size 5
      MSG
    end

    it 'explains size mismatch for array' do
      assert_equal has_size(5).failure_message([1, 2, 3]), <<~MSG.chomp
        expected [1, 2, 3] to have size 5, but had size 3
      MSG
    end

    it 'explains matcher failure for size' do
      assert_equal has_size(equals(3)).failure_message('hello'), <<~MSG.chomp
        expected "hello" to have size equal to 3, but had size 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected size match for integer' do
      assert_equal has_size(5).negated_failure_message('hello'), <<~MSG.chomp
        expected "hello" not to have size 5, but it did
      MSG
    end

    it 'explains unexpected size match for matcher' do
      assert_equal has_size(equals(5)).negated_failure_message('hello'), <<~MSG.chomp
        expected "hello" not to have size equal to 5, but it did
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(has_size(3)).matches?('hello')
      refute never(has_size(5)).matches?('hello')
    end

    it 'works with & operator' do
      assert (has_size(5) & is_a(String)).matches?('hello')
      refute (has_size(3) & is_a(String)).matches?('hello')
    end

    it 'works with | operator' do
      assert (has_size(3) | has_size(5)).matches?('hello')
      assert (has_size(3) | has_size(5)).matches?('foo')
      refute (has_size(3) | has_size(5)).matches?('hi')
    end
  end
end
