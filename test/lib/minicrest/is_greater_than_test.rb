# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsGreaterThan do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when actual is greater than expected' do
      assert is_greater_than(3).matches?(5)
    end

    it 'returns false when actual equals expected' do
      refute is_greater_than(5).matches?(5)
    end

    it 'returns false when actual is less than expected' do
      refute is_greater_than(5).matches?(3)
    end

    it 'works with floats' do
      assert is_greater_than(3.14).matches?(3.15)
      refute is_greater_than(3.14).matches?(3.14)
      refute is_greater_than(3.14).matches?(3.13)
    end

    it 'works with negative numbers' do
      assert is_greater_than(-5).matches?(-3)
      assert is_greater_than(-5).matches?(0)
      refute is_greater_than(-3).matches?(-5)
    end

    it 'works with comparable objects' do
      assert is_greater_than('apple').matches?('banana')
      refute is_greater_than('banana').matches?('apple')
    end
  end

  describe '#description' do
    it 'describes the expected comparison' do
      assert_equal 'greater than 5', is_greater_than(5).description
    end

    it 'shows float values' do
      assert_equal 'greater than 3.14', is_greater_than(3.14).description
    end
  end

  describe '#failure_message' do
    it 'explains the failed comparison' do
      assert_equal is_greater_than(5).failure_message(3), <<~MSG.chomp
        expected 3 to be greater than 5
      MSG
    end

    it 'explains equality case' do
      assert_equal is_greater_than(5).failure_message(5), <<~MSG.chomp
        expected 5 to be greater than 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected greater than' do
      assert_equal is_greater_than(3).negated_failure_message(5), <<~MSG.chomp
        expected 5 not to be greater than 3, but it was
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(is_greater_than(5)).matches?(3)
      refute never(is_greater_than(5)).matches?(10)
    end

    it 'works with & operator to define a range' do
      in_range = is_greater_than(0) & is_less_than(10)
      assert in_range.matches?(5)
      refute in_range.matches?(0)
      refute in_range.matches?(10)
      refute in_range.matches?(-1)
    end

    it 'works with | operator' do
      assert (is_greater_than(10) | equals(5)).matches?(15)
      assert (is_greater_than(10) | equals(5)).matches?(5)
      refute (is_greater_than(10) | equals(5)).matches?(7)
    end
  end
end
