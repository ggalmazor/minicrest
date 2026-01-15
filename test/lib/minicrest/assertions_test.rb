# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

# These tests specifically test the Assertions module (factory methods and assert_that),
# so they intentionally use assert_that to exercise that functionality.
describe Minicrest::Assertions do
  include Minicrest::Assertions

  describe '#assert_that' do
    it 'returns an Asserter for fluent chaining' do
      assert_kind_of Minicrest::Asserter, assert_that(42)
    end

    it 'passes when using fluent equals' do
      assert_that(42).equals(42)
    end

    it 'raises Minitest::Assertion when fluent equals does not match' do
      error = assert_raises(Minitest::Assertion) do
        assert_that(42).equals(43)
      end

      assert_equal error.message, <<~MSG.chomp
        expected 42
              to equal 43
      MSG
    end

    it 'works with is() matcher via fluent API' do
      obj = Object.new

      assert_that(obj).is(obj)
    end

    it 'works with never for matcher negation' do
      assert_that(42).never(equals(43))
    end

    it 'works with AND combinator via matches' do
      assert_that(42).matches(equals(42) & never(equals(nil)))
    end

    it 'works with OR combinator via matches' do
      assert_that(42).matches(equals(42) | equals(43))
    end
  end

  describe 'factory methods' do
    describe '#equals' do
      it 'creates an Equals matcher' do
        assert_kind_of Minicrest::Equals, equals(42)
      end
    end

    describe '#is' do
      it 'creates an Is matcher' do
        assert_kind_of Minicrest::Is, is(Object.new)
      end
    end

    describe '#never' do
      it 'creates a Not combinator' do
        assert_kind_of Minicrest::Not, never(equals(42))
      end
    end
  end

  describe 'error message quality' do
    describe 'with hash diff' do
      it 'shows detailed diff in error message' do
        error = assert_raises(Minitest::Assertion) do
          assert_that({ name: 'Bob', age: 30 }).equals({ name: 'Alice', age: 30 })
        end

        assert_equal error.message, <<~MSG.chomp
          expected {name: "Bob", age: 30}
                to equal {name: "Alice", age: 30}

          Diff:
            key :name:
              expected: "Alice"
              actual:   "Bob"
        MSG
      end
    end

    describe 'with array diff' do
      it 'shows detailed diff in error message' do
        error = assert_raises(Minitest::Assertion) do
          assert_that([1, 2, 4]).equals([1, 2, 3])
        end

        assert_equal error.message, <<~MSG.chomp
          expected [1, 2, 4]
                to equal [1, 2, 3]

          Diff:
            [2]:
              expected: 3
              actual:   4
        MSG
      end
    end

    describe 'with reference inequality' do
      it 'shows object ids in error message' do
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
  end

  describe 'integration with complex data structures' do
    it 'handles nested hash equality' do
      expected = { user: { name: 'Alice', address: { city: 'New York', zip: '10001' } } }
      actual = { user: { name: 'Alice', address: { city: 'New York', zip: '10001' } } }

      assert_that(actual).equals(expected)
    end

    it 'handles array of hashes equality' do
      expected = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }]
      actual = [{ id: 1, name: 'Alice' }, { id: 2, name: 'Bob' }]

      assert_that(actual).equals(expected)
    end
  end
end
