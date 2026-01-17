# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsGreaterThanOrEqualTo do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when actual is greater than expected' do
      assert is_greater_than_or_equal_to(3).matches?(5)
    end

    it 'returns true when actual equals expected' do
      assert is_greater_than_or_equal_to(5).matches?(5)
    end

    it 'returns false when actual is less than expected' do
      refute is_greater_than_or_equal_to(5).matches?(3)
    end

    it 'works with floats' do
      assert is_greater_than_or_equal_to(3.14).matches?(3.15)
      assert is_greater_than_or_equal_to(3.14).matches?(3.14)
      refute is_greater_than_or_equal_to(3.14).matches?(3.13)
    end
  end

  describe '#description' do
    it 'describes the expected comparison' do
      assert_equal 'greater than or equal to 5', is_greater_than_or_equal_to(5).description
    end
  end

  describe '#failure_message' do
    it 'explains the failed comparison' do
      assert_equal is_greater_than_or_equal_to(5).failure_message(3), <<~MSG.chomp
        expected 3 to be greater than or equal to 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected comparison' do
      assert_equal is_greater_than_or_equal_to(3).negated_failure_message(5), <<~MSG.chomp
        expected 5 not to be greater than or equal to 3, but it was
      MSG
    end
  end
end
