# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsCloseTo do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when value is within delta' do
      assert is_close_to(3.14, 0.01).matches?(3.14159)
    end

    it 'returns true for exact match' do
      assert is_close_to(3.14, 0.01).matches?(3.14)
    end

    it 'returns true when at lower boundary' do
      assert is_close_to(10.0, 1.0).matches?(9.0)
    end

    it 'returns true when at upper boundary' do
      assert is_close_to(10.0, 1.0).matches?(11.0)
    end

    it 'returns false when value is outside delta' do
      refute is_close_to(3.14, 0.01).matches?(3.16)
      refute is_close_to(3.14, 0.01).matches?(3.12)
    end

    it 'works with integers' do
      assert is_close_to(100, 5).matches?(102)
      assert is_close_to(100, 5).matches?(95)
      refute is_close_to(100, 5).matches?(106)
    end

    it 'works with negative numbers' do
      assert is_close_to(-10.0, 1.0).matches?(-10.0)
      assert is_close_to(-10.0, 1.0).matches?(-9.5)
      refute is_close_to(-10.0, 1.0).matches?(-5.0)
    end

    it 'works with zero' do
      assert is_close_to(0, 0.001).matches?(0.0005)
      assert is_close_to(0, 0.001).matches?(-0.0005)
      refute is_close_to(0, 0.001).matches?(0.002)
    end
  end

  describe '#description' do
    it 'describes the expected value and delta' do
      assert_equal 'close to 3.14 (within 0.01)', is_close_to(3.14, 0.01).description
    end

    it 'handles integer delta' do
      assert_equal 'close to 100 (within 5)', is_close_to(100, 5).description
    end
  end

  describe '#failure_message' do
    it 'explains the difference and delta' do
      assert_equal is_close_to(3.14, 0.01).failure_message(3.2), <<~MSG.chomp
        expected 3.2 to be close to 3.14 (within 0.01), but difference was 0.06
      MSG
    end

    it 'handles negative differences' do
      assert_equal is_close_to(3.14, 0.01).failure_message(3.0), <<~MSG.chomp
        expected 3.0 to be close to 3.14 (within 0.01), but difference was 0.14
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected closeness' do
      assert_equal is_close_to(3.14, 0.01).negated_failure_message(3.14), <<~MSG.chomp
        expected 3.14 not to be close to 3.14 (within 0.01), but it was
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(is_close_to(3.14, 0.01)).matches?(5.0)
      refute never(is_close_to(3.14, 0.01)).matches?(3.14)
    end

    it 'works with | operator' do
      pi_or_e = is_close_to(3.14159, 0.001) | is_close_to(2.71828, 0.001)
      assert pi_or_e.matches?(3.14159)
      assert pi_or_e.matches?(2.71828)
      refute pi_or_e.matches?(1.0)
    end
  end
end
