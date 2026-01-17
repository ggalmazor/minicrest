# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Contains do
  include Minicrest::Assertions

  describe 'with arrays' do
    describe '#matches?' do
      it 'matches array with same elements in different order' do
        assert contains(1, 2, 3).matches?([3, 1, 2])
      end

      it 'matches array with same elements in same order' do
        assert contains(1, 2, 3).matches?([1, 2, 3])
      end

      it 'does not match array with extra elements' do
        refute contains(1, 2).matches?([1, 2, 3])
      end

      it 'does not match array with missing elements' do
        refute contains(1, 2, 3, 4).matches?([1, 2, 3])
      end

      it 'matches empty array with no elements' do
        assert contains.matches?([])
      end
    end

    describe '#failure_message' do
      it 'shows difference when extra elements' do
        assert_equal contains(1, 2).failure_message([1, 2, 3]), <<~MSG.chomp
          expected [1, 2, 3] to contain exactly 1, 2 (in any order)
          extra: 3
        MSG
      end

      it 'shows difference when missing elements' do
        assert_equal contains(1, 2, 3, 4).failure_message([1, 2, 3]), <<~MSG.chomp
          expected [1, 2, 3] to contain exactly 1, 2, 3, 4 (in any order)
          missing: 4
        MSG
      end

      it 'shows both when extra and missing' do
        assert_equal contains(1, 2, 4).failure_message([1, 2, 3]), <<~MSG.chomp
          expected [1, 2, 3] to contain exactly 1, 2, 4 (in any order)
          missing: 4
          extra: 3
        MSG
      end
    end
  end

  describe 'with hashes' do
    describe '#matches?' do
      it 'matches hash with same pairs in different order' do
        assert contains(a: 1, b: 2).matches?({ b: 2, a: 1 })
      end

      it 'does not match hash with extra pairs' do
        refute contains(a: 1).matches?({ a: 1, b: 2 })
      end

      it 'does not match hash with missing pairs' do
        refute contains(a: 1, b: 2, c: 3).matches?({ a: 1, b: 2 })
      end
    end
  end

  describe '#description' do
    it 'describes expected items' do
      assert_equal 'contains exactly 1, 2, 3 (in any order)', contains(1, 2, 3).description
    end

    it 'describes hash pairs' do
      assert_equal 'contains exactly {a: 1, b: 2} (in any order)', contains(a: 1, b: 2).description
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected match' do
      assert_equal contains(1, 2, 3).negated_failure_message([3, 1, 2]), <<~MSG.chomp
        expected [3, 1, 2] not to contain exactly 1, 2, 3 (in any order), but it did
      MSG
    end
  end
end
