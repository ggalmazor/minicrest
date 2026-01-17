# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::AllItems do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when all items match the matcher' do
      assert all_items(is_a(Integer)).matches?([1, 2, 3])
    end

    it 'does not match when one item fails' do
      refute all_items(is_a(Integer)).matches?([1, 'two', 3])
    end

    it 'matches empty array' do
      assert all_items(is_a(Integer)).matches?([])
    end

    it 'works with comparison matchers' do
      assert all_items(is_greater_than(0)).matches?([1, 2, 3])
      refute all_items(is_greater_than(0)).matches?([1, 0, 3])
    end

    it 'works with combined matchers' do
      positive_even = is_greater_than(0) & equals(2) | equals(4) | equals(6)
      assert all_items(positive_even).matches?([2, 4, 6])
    end
  end

  describe '#description' do
    it 'describes the item matcher' do
      assert_equal 'all items are an instance of Integer', all_items(is_a(Integer)).description
    end

    it 'describes comparison matcher' do
      assert_equal 'all items are greater than 0', all_items(is_greater_than(0)).description
    end
  end

  describe '#failure_message' do
    it 'shows failing item and index' do
      assert_equal all_items(is_a(Integer)).failure_message([1, 'two', 3]), <<~MSG.chomp
        expected all items to be an instance of Integer
        item at index 1 failed:
          expected "two"
                to be an instance of Integer
          but was String
      MSG
    end

    it 'shows first failing item when multiple fail' do
      result = all_items(is_a(Integer)).failure_message(['one', 'two', 'three'])
      assert_includes result, 'item at index 0 failed'
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected match' do
      assert_equal all_items(is_a(Integer)).negated_failure_message([1, 2, 3]), <<~MSG.chomp
        expected not all items to be an instance of Integer, but they all matched
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(all_items(is_a(Integer))).matches?([1, 'two', 3])
      refute never(all_items(is_a(Integer))).matches?([1, 2, 3])
    end
  end
end
