# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Not do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'negates a matching result' do
      refute never(equals(5)).matches?(5)
    end

    it 'negates a non-matching result' do
      assert never(equals(5)).matches?(3)
    end

    it 'works with is() matcher' do
      obj = Object.new
      other = Object.new

      assert never(is(obj)).matches?(other)
      refute never(is(obj)).matches?(obj)
    end

    it 'supports double negation' do
      # not(not(equals(5))) should match 5
      assert never(never(equals(5))).matches?(5)
    end
  end

  describe '#description' do
    it "prepends 'not' to the inner matcher's description" do
      matcher = never(equals(42))

      assert_equal 'not equal to 42', matcher.description
    end

    it 'works with complex inner matchers' do
      matcher = never(equals({ a: 1, b: [2, 3] }))

      assert_equal 'not equal to {a: 1, b: [2, 3]}', matcher.description
    end
  end

  describe '#failure_message' do
    it "delegates to inner matcher's negated_failure_message when negation fails" do
      matcher = never(equals(42))
      message = matcher.failure_message(42)

      assert_equal message, <<~MSG.chomp
        expected 42
          not to equal 42, but they are equal
      MSG
    end

    it 'provides clear message for complex structures' do
      expected = { status: 'active' }
      matcher = never(equals(expected))
      message = matcher.failure_message(expected)

      assert_equal message, <<~MSG.chomp
        expected {status: "active"}
          not to equal {status: "active"}, but they are equal
      MSG
    end
  end

  describe '#negated_failure_message' do
    it "delegates to inner matcher's failure_message" do
      matcher = never(equals(42))
      message = matcher.negated_failure_message(43)

      assert_equal message, <<~MSG.chomp
        expected 43
              to equal 42
      MSG
    end
  end

  describe 'fluent never' do
    it 'works with assert_that fluent API' do
      assert_that(3).never(equals(5))
      assert_that(5).never(equals(3))
    end

    it 'negates equals matcher' do
      assert_that(nil).never(equals(0))
      assert_that('').never(equals(nil))
    end
  end
end

describe Minicrest::And do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when both matchers match' do
      matcher = equals(5) & equals(5)

      assert matcher.matches?(5)
    end

    it 'returns false when left matcher fails' do
      matcher = equals(5) & equals(5)

      refute matcher.matches?(3)
    end

    it 'returns false when right matcher fails' do
      matcher = equals(5) & never(equals(5))

      refute matcher.matches?(5)
    end

    it 'supports chaining multiple AND combinators' do
      matcher = equals(5) & never(equals(nil)) & never(equals(0))

      assert matcher.matches?(5)
      refute matcher.matches?(nil)
      refute matcher.matches?(0)
    end
  end

  describe '#description' do
    it "combines both descriptions with 'and'" do
      matcher = equals(5) & never(equals(nil))

      assert_equal '(equal to 5 and not equal to nil)', matcher.description
    end

    it 'handles nested AND combinators' do
      matcher = equals(1) & equals(2) & equals(3)

      assert_equal '((equal to 1 and equal to 2) and equal to 3)', matcher.description
    end
  end

  describe '#failure_message' do
    it 'shows which matcher failed when only right fails' do
      matcher = equals(5) & equals(6)
      message = matcher.failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5
              to equal 6
      MSG
    end

    it 'shows which matcher failed when only left fails' do
      matcher = equals(5) & equals(3)
      message = matcher.failure_message(3)

      assert_equal message, <<~MSG.chomp
        expected 3
              to equal 5
      MSG
    end

    it 'shows both failures when both fail' do
      matcher = equals(5) & equals(6)
      message = matcher.failure_message(7)

      assert_equal message, <<~MSG.chomp
        expected 7
              to equal 5
          AND
        expected 7
              to equal 6
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that both conditions unexpectedly matched' do
      matcher = equals(5) & equals(5)
      message = matcher.negated_failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 not to match both conditions:
          equal to 5
          equal to 5
        but it matched both
      MSG
    end
  end
end

describe Minicrest::Or do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when left matcher matches' do
      matcher = equals(5) | equals(10)

      assert matcher.matches?(5)
    end

    it 'returns true when right matcher matches' do
      matcher = equals(5) | equals(10)

      assert matcher.matches?(10)
    end

    it 'returns true when both matchers match' do
      matcher = equals(5) | equals(5) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands

      assert matcher.matches?(5)
    end

    it 'returns false when neither matcher matches' do
      matcher = equals(5) | equals(10)

      refute matcher.matches?(7)
    end

    it 'supports chaining multiple OR combinators' do
      matcher = equals(1) | equals(2) | equals(3)

      assert matcher.matches?(1)
      assert matcher.matches?(2)
      assert matcher.matches?(3)
      refute matcher.matches?(4)
    end
  end

  describe '#description' do
    it "combines both descriptions with 'or'" do
      matcher = equals(5) | equals(10)

      assert_equal '(equal to 5 or equal to 10)', matcher.description
    end

    it 'handles chained OR combinators' do
      matcher = equals(1) | equals(2) | equals(3)

      assert_equal '((equal to 1 or equal to 2) or equal to 3)', matcher.description
    end
  end

  describe '#failure_message' do
    it 'explains that neither condition matched' do
      matcher = equals(5) | equals(10)
      message = matcher.failure_message(7)

      assert_equal message, <<~MSG.chomp
        expected 7 to match at least one of:
          equal to 5
          equal to 10
        but it matched neither:
          expected 7
              to equal 5
          expected 7
              to equal 10
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains which condition unexpectedly matched' do
      matcher = equals(5) | equals(10)
      message = matcher.negated_failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 not to match either condition, but it matched:
          equal to 5
      MSG
    end

    it 'shows both when both match' do
      matcher = equals(5) | equals(5) # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      message = matcher.negated_failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 not to match either condition, but it matched:
          equal to 5
          equal to 5
      MSG
    end
  end
end

describe 'Combined combinators' do
  include Minicrest::Assertions

  describe 'AND with OR' do
    it 'evaluates correctly with parentheses' do
      matcher = (equals(5) | equals(10)) & never(equals(nil))

      assert matcher.matches?(5)
      assert matcher.matches?(10)
      refute matcher.matches?(nil)
      refute matcher.matches?(7)
    end
  end

  describe 'OR with AND' do
    it 'evaluates correctly with parentheses' do
      left = equals(5) & never(equals(nil))
      right = equals(10) & never(equals(nil))
      matcher = left | right

      assert matcher.matches?(5)
      assert matcher.matches?(10)
      refute matcher.matches?(nil)
      refute matcher.matches?(7)
    end
  end

  describe 'complex nested expressions' do
    it 'handles multiple levels of nesting' do
      matcher = (equals(1) | equals(2) | equals(3)) & never(equals(nil))

      assert matcher.matches?(1)
      assert matcher.matches?(2)
      assert matcher.matches?(3)
      refute matcher.matches?(4)
      refute matcher.matches?(nil)
    end
  end
end

describe Minicrest::All do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when all matchers match' do
      matcher = all_of(equals(5), never(equals(nil)), never(equals(0)))

      assert matcher.matches?(5)
    end

    it 'returns false when any matcher fails' do
      matcher = all_of(equals(5), equals(6))

      refute matcher.matches?(5)
    end

    it 'returns false when all matchers fail' do
      matcher = all_of(equals(5), equals(6))

      refute matcher.matches?(7)
    end

    it 'works with many matchers' do
      matcher = all_of(
        never(equals(nil)),
        never(equals(0)),
        never(equals('')),
        never(is(false))
      )

      assert matcher.matches?(42)
      refute matcher.matches?(nil)
      refute matcher.matches?(0)
    end
  end

  describe '#description' do
    it "lists all matchers with 'all of'" do
      matcher = all_of(equals(5), equals(6), never(equals(nil)))

      assert_equal 'all of: equal to 5, equal to 6, not equal to nil', matcher.description
    end
  end

  describe '#failure_message' do
    it 'shows all matchers and which ones failed' do
      matcher = all_of(equals(5), equals(6), equals(7))
      message = matcher.failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 to match all of:
          equal to 5
          equal to 6
          equal to 7
        but failed:
          expected 5
              to equal 6
          expected 5
              to equal 7
      MSG
    end

    it 'shows only the failing matchers in failure section' do
      matcher = all_of(equals(5), equals(6))
      message = matcher.failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 to match all of:
          equal to 5
          equal to 6
        but failed:
          expected 5
              to equal 6
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that all conditions unexpectedly matched' do
      matcher = all_of(equals(5), equals(5))
      message = matcher.negated_failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 not to match all conditions, but it matched all:
          equal to 5
          equal to 5
      MSG
    end
  end
end

describe Minicrest::None do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when no matchers match' do
      matcher = none_of(equals(5), equals(6), equals(7))

      assert matcher.matches?(10)
    end

    it 'returns false when any matcher matches' do
      matcher = none_of(equals(5), equals(6), equals(7))

      refute matcher.matches?(5)
      refute matcher.matches?(6)
      refute matcher.matches?(7)
    end

    it 'returns false when all matchers match' do
      matcher = none_of(equals(5), equals(5))

      refute matcher.matches?(5)
    end
  end

  describe '#description' do
    it "lists all matchers with 'none of'" do
      matcher = none_of(equals(5), equals(6), equals(7))

      assert_equal 'none of: equal to 5, equal to 6, equal to 7', matcher.description
    end
  end

  describe '#failure_message' do
    it 'shows which matchers unexpectedly matched' do
      matcher = none_of(equals(5), equals(6), equals(7))
      message = matcher.failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 to match none of:
          equal to 5
          equal to 6
          equal to 7
        but matched:
          equal to 5
      MSG
    end

    it 'shows multiple matches when several matchers match' do
      matcher = none_of(equals(5), equals(5), equals(6))
      message = matcher.failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 to match none of:
          equal to 5
          equal to 5
          equal to 6
        but matched:
          equal to 5
          equal to 5
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that unexpectedly nothing matched' do
      matcher = none_of(equals(5), equals(6))
      message = matcher.negated_failure_message(10)

      assert_equal message, <<~MSG.chomp
        expected 10 to match at least one of:
          equal to 5
          equal to 6
        but matched none
      MSG
    end
  end
end

describe Minicrest::Some do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'returns true when one matcher matches' do
      matcher = some_of(equals(5), equals(6), equals(7))

      assert matcher.matches?(5)
    end

    it 'returns true when multiple matchers match' do
      matcher = some_of(equals(5), equals(5), equals(6))

      assert matcher.matches?(5)
    end

    it 'returns false when no matchers match' do
      matcher = some_of(equals(5), equals(6), equals(7))

      refute matcher.matches?(10)
    end
  end

  describe '#description' do
    it "lists all matchers with 'some of'" do
      matcher = some_of(equals(5), equals(6), equals(7))

      assert_equal 'some of: equal to 5, equal to 6, equal to 7', matcher.description
    end
  end

  describe '#failure_message' do
    it 'shows all options and explains none matched' do
      matcher = some_of(equals(5), equals(6), equals(7))
      message = matcher.failure_message(10)

      assert_equal message, <<~MSG.chomp
        expected 10 to match at least one of:
          equal to 5
          equal to 6
          equal to 7
        but matched none:
          expected 10
              to equal 5
          expected 10
              to equal 6
          expected 10
              to equal 7
      MSG
    end

    it 'shows detailed failure reasons' do
      matcher = some_of(equals(5), equals(6))
      message = matcher.failure_message(10)

      assert_equal message, <<~MSG.chomp
        expected 10 to match at least one of:
          equal to 5
          equal to 6
        but matched none:
          expected 10
              to equal 5
          expected 10
              to equal 6
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains which matchers unexpectedly matched' do
      matcher = some_of(equals(5), equals(6), equals(7))
      message = matcher.negated_failure_message(5)

      assert_equal message, <<~MSG.chomp
        expected 5 to match none of the conditions, but matched:
          equal to 5
      MSG
    end
  end
end
