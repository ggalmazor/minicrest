# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::NoItems do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when no items match' do
      assert no_items(is_a(String)).matches?([1, 2, 3])
    end

    it 'does not match when one item matches' do
      refute no_items(is_a(String)).matches?([1, 'two', 3])
    end

    it 'matches empty array' do
      assert no_items(is_a(String)).matches?([])
    end

    it 'works with comparison matchers' do
      assert no_items(is_greater_than(10)).matches?([1, 2, 3])
      refute no_items(is_greater_than(0)).matches?([1, 2, 3])
    end
  end

  describe '#description' do
    it 'describes the item matcher' do
      assert_equal 'no items are an instance of String', no_items(is_a(String)).description
    end
  end

  describe '#failure_message' do
    it 'shows which item matched' do
      assert_equal no_items(is_a(String)).failure_message([1, 'two', 3]), <<~MSG.chomp
        expected no items to be an instance of String
        but item at index 1 matched: "two"
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that no items matched' do
      assert_equal no_items(is_a(String)).negated_failure_message([1, 2, 3]), <<~MSG.chomp
        expected some items to be an instance of String
        but no items matched
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(no_items(is_a(String))).matches?([1, 'two', 3])
      refute never(no_items(is_a(String))).matches?([1, 2, 3])
    end
  end
end
