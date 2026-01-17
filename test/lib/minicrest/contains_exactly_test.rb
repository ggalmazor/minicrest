# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::ContainsExactly do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches array with same elements in same order' do
      assert contains_exactly(1, 2, 3).matches?([1, 2, 3])
    end

    it 'does not match array with same elements in different order' do
      refute contains_exactly(1, 2, 3).matches?([3, 1, 2])
    end

    it 'does not match array with extra elements' do
      refute contains_exactly(1, 2).matches?([1, 2, 3])
    end

    it 'does not match array with missing elements' do
      refute contains_exactly(1, 2, 3, 4).matches?([1, 2, 3])
    end

    it 'matches empty array with no elements' do
      assert contains_exactly.matches?([])
    end
  end

  describe '#description' do
    it 'describes expected items' do
      assert_equal 'contains exactly [1, 2, 3] (in order)', contains_exactly(1, 2, 3).description
    end
  end

  describe '#failure_message' do
    it 'shows difference when wrong order' do
      assert_equal contains_exactly(1, 2, 3).failure_message([3, 1, 2]), <<~MSG.chomp
        expected [3, 1, 2] to contain exactly [1, 2, 3] (in order)
        at index 0: expected 1, got 3
        at index 1: expected 2, got 1
        at index 2: expected 3, got 2
      MSG
    end

    it 'shows difference when different size' do
      assert_equal contains_exactly(1, 2).failure_message([1, 2, 3]), <<~MSG.chomp
        expected [1, 2, 3] to contain exactly [1, 2] (in order)
        expected size 2, got 3
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected match' do
      assert_equal contains_exactly(1, 2, 3).negated_failure_message([1, 2, 3]), <<~MSG.chomp
        expected [1, 2, 3] not to contain exactly [1, 2, 3] (in order), but it did
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(contains_exactly(1, 2, 3)).matches?([3, 1, 2])
      refute never(contains_exactly(1, 2, 3)).matches?([1, 2, 3])
    end
  end
end
