# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsLessThanOrEqualTo do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when actual is less than expected' do
      assert is_less_than_or_equal_to(5).matches?(3)
    end

    it 'returns true when actual equals expected' do
      assert is_less_than_or_equal_to(5).matches?(5)
    end

    it 'returns false when actual is greater than expected' do
      refute is_less_than_or_equal_to(3).matches?(5)
    end

    it 'works with floats' do
      assert is_less_than_or_equal_to(3.14).matches?(3.13)
      assert is_less_than_or_equal_to(3.14).matches?(3.14)
      refute is_less_than_or_equal_to(3.14).matches?(3.15)
    end
  end

  describe '#description' do
    it 'describes the expected comparison' do
      assert_equal 'less than or equal to 5', is_less_than_or_equal_to(5).description
    end
  end

  describe '#failure_message' do
    it 'explains the failed comparison' do
      assert_equal is_less_than_or_equal_to(5).failure_message(10), <<~MSG.chomp
        expected 10 to be less than or equal to 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected comparison' do
      assert_equal is_less_than_or_equal_to(5).negated_failure_message(3), <<~MSG.chomp
        expected 3 not to be less than or equal to 5, but it was
      MSG
    end
  end
end
