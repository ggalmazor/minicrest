# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Asserter do
  include Minicrest::Assertions

  describe '#equals' do
    it 'passes when values are equal' do
      assert_that(42).equals(42)
    end

    it 'fails when values are not equal' do
      error = assert_raises(Minitest::Assertion) do
        assert_that(42).equals(43)
      end

      assert_equal error.message, <<~MSG.chomp
        expected 42
              to equal 43
      MSG
    end

    it 'supports deep equality for arrays' do
      assert_that([1, 2, 3]).equals([1, 2, 3])
    end

    it 'supports deep equality for hashes' do
      assert_that({ a: 1, b: 2 }).equals({ a: 1, b: 2 })
    end
  end

  describe '#is' do
    it 'passes for same object reference' do
      obj = Object.new
      assert_that(obj).is(obj)
    end

    it 'fails for different objects' do
      obj1 = Object.new
      obj2 = Object.new

      error = assert_raises(Minitest::Assertion) do
        assert_that(obj1).is(obj2)
      end

      assert_equal error.message, <<~MSG.chomp
        expected #{obj1.inspect} (object_id: #{obj1.object_id}) to be the same object as #{obj2.inspect} (object_id: #{obj2.object_id})
      MSG
    end
  end

  describe '#never' do
    it 'passes when matcher does not match' do
      assert_that(42).never(equals(43))
    end

    it 'fails when matcher matches' do
      error = assert_raises(Minitest::Assertion) do
        assert_that(42).never(equals(42))
      end

      assert_equal error.message, <<~MSG.chomp
        expected 42
          not to equal 42, but they are equal
      MSG
    end
  end

  describe '#matches' do
    it 'passes when matcher matches' do
      assert_that(42).matches(equals(42))
    end

    it 'fails when matcher does not match' do
      error = assert_raises(Minitest::Assertion) do
        assert_that(42).matches(equals(43))
      end

      assert_equal error.message, <<~MSG.chomp
        expected 42
              to equal 43
      MSG
    end

    it 'works with combined matchers (OR)' do
      assert_that(42).matches(equals(42) | equals(43))
      assert_that(43).matches(equals(42) | equals(43))
    end

    it 'works with combined matchers (AND)' do
      assert_that(42).matches(equals(42) & never(equals(nil)))
    end

    it 'fails with combined matchers when condition not met' do
      error = assert_raises(Minitest::Assertion) do
        assert_that(44).matches(equals(42) | equals(43))
      end

      assert_equal error.message, <<~MSG.chomp
        expected 44 to match at least one of:
          equal to 42
          equal to 43
        but it matched neither:
          expected 44
              to equal 42
          expected 44
              to equal 43
      MSG
    end
  end

  describe 'readability examples' do
    it 'reads naturally for value assertions' do
      result = 42
      assert_that(result).equals(42)
    end

    it 'reads naturally for nil checks using never' do
      value = 'not nil'
      assert_that(value).never(equals(nil))
    end

    it 'reads naturally for reference checks' do
      singleton = Object.new
      reference = singleton
      assert_that(reference).is(singleton)
    end

    it 'reads naturally for either/or conditions' do
      status = 'active'
      assert_that(status).matches(equals('active') | equals('pending'))
    end
  end
end
