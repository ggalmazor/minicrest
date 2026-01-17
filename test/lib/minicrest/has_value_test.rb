# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::HasValue do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when hash contains single value' do
      assert has_value(1).matches?({ a: 1, b: 2 })
    end

    it 'matches when hash contains multiple values' do
      assert has_value(1, 2).matches?({ a: 1, b: 2, c: 3 })
    end

    it 'does not match when hash missing value' do
      refute has_value(5).matches?({ a: 1, b: 2 })
    end

    it 'does not match when hash missing any value' do
      refute has_value(1, 5).matches?({ a: 1, b: 2 })
    end

    it 'works with string values' do
      assert has_value('Alice').matches?({ name: 'Alice', age: 30 })
    end
  end

  describe '#description' do
    it 'describes single value' do
      assert_equal 'has value 1', has_value(1).description
    end

    it 'describes multiple values' do
      assert_equal 'has values 1, 2', has_value(1, 2).description
    end
  end

  describe '#failure_message' do
    it 'lists missing values' do
      assert_equal has_value(5, 6).failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} to have values 5, 6
        missing: 5, 6
      MSG
    end

    it 'shows only missing values when some present' do
      assert_equal has_value(1, 5).failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} to have values 1, 5
        missing: 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected value presence' do
      assert_equal has_value(1).negated_failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} not to have value 1, but it did
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(has_value(5)).matches?({ a: 1, b: 2 })
      refute never(has_value(1)).matches?({ a: 1, b: 2 })
    end

    it 'works with & operator' do
      assert (has_value(1) & has_value(2)).matches?({ a: 1, b: 2 })
      refute (has_value(1) & has_value(5)).matches?({ a: 1, b: 2 })
    end
  end
end
