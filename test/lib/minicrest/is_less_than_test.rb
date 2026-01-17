# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsLessThan do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when actual is less than expected' do
      assert is_less_than(5).matches?(3)
    end

    it 'returns false when actual equals expected' do
      refute is_less_than(5).matches?(5)
    end

    it 'returns false when actual is greater than expected' do
      refute is_less_than(3).matches?(5)
    end

    it 'works with floats' do
      assert is_less_than(3.14).matches?(3.13)
      refute is_less_than(3.14).matches?(3.14)
      refute is_less_than(3.14).matches?(3.15)
    end

    it 'works with negative numbers' do
      assert is_less_than(-3).matches?(-5)
      assert is_less_than(0).matches?(-5)
      refute is_less_than(-5).matches?(-3)
    end

    it 'works with comparable objects' do
      assert is_less_than('banana').matches?('apple')
      refute is_less_than('apple').matches?('banana')
    end
  end

  describe '#description' do
    it 'describes the expected comparison' do
      assert_equal 'less than 5', is_less_than(5).description
    end

    it 'shows float values' do
      assert_equal 'less than 3.14', is_less_than(3.14).description
    end
  end

  describe '#failure_message' do
    it 'explains the failed comparison' do
      assert_equal is_less_than(5).failure_message(10), <<~MSG.chomp
        expected 10 to be less than 5
      MSG
    end

    it 'explains equality case' do
      assert_equal is_less_than(5).failure_message(5), <<~MSG.chomp
        expected 5 to be less than 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected less than' do
      assert_equal is_less_than(5).negated_failure_message(3), <<~MSG.chomp
        expected 3 not to be less than 5, but it was
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(is_less_than(5)).matches?(10)
      refute never(is_less_than(5)).matches?(3)
    end

    it 'works with & operator to define a range' do
      in_range = is_greater_than(0) & is_less_than(10)
      assert in_range.matches?(5)
      refute in_range.matches?(0)
      refute in_range.matches?(10)
    end

    it 'works with | operator' do
      assert (is_less_than(5) | equals(10)).matches?(3)
      assert (is_less_than(5) | equals(10)).matches?(10)
      refute (is_less_than(5) | equals(10)).matches?(7)
    end
  end
end
