# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::SomeItems do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when one item matches' do
      assert some_items(descends_from(String)).matches?([1, 'two', 3])
    end

    it 'matches when multiple items match' do
      assert some_items(descends_from(Integer)).matches?([1, 2, 'three'])
    end

    it 'does not match when no items match' do
      refute some_items(descends_from(String)).matches?([1, 2, 3])
    end

    it 'does not match empty array' do
      refute some_items(descends_from(Integer)).matches?([])
    end

    it 'works with comparison matchers' do
      assert some_items(is_greater_than(5)).matches?([1, 2, 10])
      refute some_items(is_greater_than(5)).matches?([1, 2, 3])
    end
  end

  describe '#description' do
    it 'describes the item matcher' do
      assert_equal 'some items are an instance of String', some_items(descends_from(String)).description
    end
  end

  describe '#failure_message' do
    it 'explains that no items matched' do
      assert_equal some_items(descends_from(String)).failure_message([1, 2, 3]), <<~MSG.chomp
        expected some items to be an instance of String
        but no items matched
      MSG
    end

    it 'explains empty array case' do
      assert_equal some_items(descends_from(String)).failure_message([]), <<~MSG.chomp
        expected some items to be an instance of String
        but no items matched
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains which items matched' do
      assert_equal some_items(descends_from(String)).negated_failure_message([1, 'two', 3]), <<~MSG.chomp
        expected no items to be an instance of String
        but item at index 1 matched: "two"
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(some_items(descends_from(String))).matches?([1, 2, 3])
      refute never(some_items(descends_from(String))).matches?([1, 'two', 3])
    end
  end
end
