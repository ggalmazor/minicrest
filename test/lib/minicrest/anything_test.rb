# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Anything do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches integers' do
      assert anything.matches?(42)
    end

    it 'matches strings' do
      assert anything.matches?('hello world')
    end

    it 'matches floats' do
      assert anything.matches?(3.14159)
    end

    it 'matches nil' do
      assert anything.matches?(nil)
    end

    it 'matches true' do
      assert anything.matches?(true)
    end

    it 'matches false' do
      assert anything.matches?(false)
    end

    it 'matches symbols' do
      assert anything.matches?(:some_symbol)
    end

    it 'matches arrays' do
      assert anything.matches?([1, 2, 3])
    end

    it 'matches empty arrays' do
      assert anything.matches?([])
    end

    it 'matches hashes' do
      assert anything.matches?({ a: 1, b: 2 })
    end

    it 'matches empty hashes' do
      assert anything.matches?({})
    end

    it 'matches objects' do
      assert anything.matches?(Object.new)
    end

    it 'matches complex nested structures' do
      complex_data = {
        users: [
          { id: 1, name: 'Alice', roles: %i[admin user] },
          { id: 2, name: 'Bob', roles: [:user] }
        ],
        metadata: {
          version: '1.0',
          generated_at: nil
        }
      }

      assert anything.matches?(complex_data)
    end
  end

  describe '#description' do
    it "returns 'anything'" do
      assert_equal 'anything', anything.description
    end
  end

  describe '#failure_message' do
    it 'explains that anything should always match for integers' do
      assert_equal anything.failure_message(42), <<~MSG.chomp
        expected 42 to be anything (this should never fail)
      MSG
    end

    it 'explains that anything should always match for nil' do
      assert_equal anything.failure_message(nil), <<~MSG.chomp
        expected nil to be anything (this should never fail)
      MSG
    end

    it 'explains that anything should always match for strings' do
      assert_equal anything.failure_message('test'), <<~MSG.chomp
        expected "test" to be anything (this should never fail)
      MSG
    end

    it 'explains that anything should always match for complex structures' do
      assert_equal anything.failure_message({ data: [1, 2, 3] }), <<~MSG.chomp
        expected {data: [1, 2, 3]} to be anything (this should never fail)
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that everything is something for integers' do
      assert_equal anything.negated_failure_message(42), <<~MSG.chomp
        expected 42 not to be anything, but everything is something
      MSG
    end

    it 'explains that everything is something for nil' do
      assert_equal anything.negated_failure_message(nil), <<~MSG.chomp
        expected nil not to be anything, but everything is something
      MSG
    end

    it 'explains that everything is something for strings' do
      assert_equal anything.negated_failure_message('hello'), <<~MSG.chomp
        expected "hello" not to be anything, but everything is something
      MSG
    end

    it 'explains that everything is something for complex structures' do
      assert_equal anything.negated_failure_message({ items: %w[a b c] }), <<~MSG.chomp
        expected {items: ["a", "b", "c"]} not to be anything, but everything is something
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never (always fails)' do
      refute never(anything).matches?(42)
    end

    it 'works with all_of' do
      assert all_of(anything, equals(42)).matches?(42)
    end

    it 'works with some_of' do
      assert some_of(anything, equals(999)).matches?(42)
    end

    it 'works with none_of (anything prevents match)' do
      refute none_of(anything).matches?(42)
    end

    it 'works with | operator' do
      assert (anything | equals(999)).matches?(42)
    end

    it 'works with & operator' do
      assert (anything & equals(42)).matches?(42)
    end
  end
end
