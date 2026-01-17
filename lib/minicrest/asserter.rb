# frozen_string_literal: true

require 'minitest/assertions'

module Minicrest
  # Fluent assertion wrapper that enables comma-free assertion syntax.
  #
  # @example Basic usage
  #   assert_that(42).equals(42)
  #   assert_that(obj).is(same_obj)
  #   assert_that(obj1).is_not(obj2)
  #   assert_that(value).does_not(equals(nil))
  #
  # @example With combined matchers
  #   assert_that(value).matches(equals(1) | equals(2))
  #   assert_that(value).matches(does_not(equals(nil)) & does_not(equals("")))
  #
  # @example With block for error assertions
  #   assert_that { raise "boom" }.raises_error
  #   assert_that { safe_operation }.raises_nothing
  class Asserter
    # Creates a new asserter for the given value or block.
    #
    # @param actual [Object, nil] the value to assert against
    # @param message [String, nil] optional message prefix for failures
    # @yield block to execute for error assertions
    def initialize(actual, message = nil, &block)
      @actual = actual
      @message = message
      @block = block
    end

    # Asserts that actual equals expected by value (deep equality).
    #
    # @param expected [Object] the expected value
    # @return [true] if assertion passes
    def equals(expected)
      matches(Equals.new(expected))
    end

    # Asserts that actual is the same object as expected (reference equality).
    #
    # @param expected [Object] the expected object reference
    # @return [true] if assertion passes
    def is(expected)
      matches(Is.new(expected))
    end

    # Asserts that actual is an instance of expected_type.
    #
    # @param expected_type [Class, Module] the expected type
    # @return [true] if assertion passes
    def descends_from(expected_type)
      matches(DescendsFrom.new(expected_type))
    end

    # Asserts that actual is an instance of expected_type.
    #
    # @param expected_type [Class] the expected type
    # @return [true] if assertion passes
    def instance_of(expected_type)
      matches(InstanceOf.new(expected_type))
    end

    # Asserts that actual is nil.
    #
    # @return [true] if assertion passes
    def nil_value
      matches(NilValue.new)
    end

    # Asserts that actual is truthy.
    #
    # @return [true] if assertion passes
    def truthy
      matches(Truthy.new)
    end

    # Asserts that actual is falsy.
    #
    # @return [true] if assertion passes
    def falsy
      matches(Falsy.new)
    end

    # Asserts that actual responds to given methods.
    #
    # @param methods [Array<Symbol>] the methods to check
    # @return [true] if assertion passes
    def responds_to(*methods)
      matches(RespondsTo.new(*methods))
    end

    # Asserts that actual starts with prefix.
    #
    # @param prefix [String] the prefix
    # @return [true] if assertion passes
    def starts_with(prefix)
      matches(StartsWith.new(prefix))
    end

    # Asserts that actual ends with suffix.
    #
    # @param suffix [String] the suffix
    # @return [true] if assertion passes
    def ends_with(suffix)
      matches(EndsWith.new(suffix))
    end

    # Asserts that actual matches pattern.
    #
    # @param pattern [Regexp] the pattern
    # @return [true] if assertion passes
    def matches_pattern(pattern)
      matches(MatchesPattern.new(pattern))
    end

    # Asserts that actual is blank.
    #
    # @return [true] if assertion passes
    def blank
      matches(Blank.new)
    end

    # Asserts that actual is empty.
    #
    # @return [true] if assertion passes
    def empty
      matches(Empty.new)
    end

    # Asserts that actual has expected size.
    #
    # @param expected [Integer, Matcher] the size or matcher
    # @return [true] if assertion passes
    def has_size(expected)
      matches(HasSize.new(expected))
    end

    # Asserts that actual is greater than expected.
    #
    # @param expected [Comparable] the value
    # @return [true] if assertion passes
    def is_greater_than(expected)
      matches(IsGreaterThan.new(expected))
    end

    # Asserts that actual is less than expected.
    #
    # @param expected [Comparable] the value
    # @return [true] if assertion passes
    def is_less_than(expected)
      matches(IsLessThan.new(expected))
    end

    # Asserts that actual is greater than or equal to expected.
    #
    # @param expected [Comparable] the value
    # @return [true] if assertion passes
    def is_greater_than_or_equal_to(expected)
      matches(IsGreaterThanOrEqualTo.new(expected))
    end

    # Asserts that actual is less than or equal to expected.
    #
    # @param expected [Comparable] the value
    # @return [true] if assertion passes
    def is_less_than_or_equal_to(expected)
      matches(IsLessThanOrEqualTo.new(expected))
    end

    # Asserts that actual is between min and max.
    #
    # @param min [Comparable] minimum
    # @param max [Comparable] maximum
    # @param exclusive [Boolean] whether exclusive
    # @return [true] if assertion passes
    def between(min, max, exclusive: false)
      matches(Between.new(min, max, exclusive:))
    end

    # Asserts that actual is close to expected.
    #
    # @param expected [Numeric] expected
    # @param delta [Numeric] delta
    # @return [true] if assertion passes
    def is_close_to(expected, delta)
      matches(IsCloseTo.new(expected, delta))
    end

    # Asserts that actual includes items.
    #
    # @param items [Array] items
    # @return [true] if assertion passes
    def includes(*items)
      matches(Includes.new(*items))
    end

    # Asserts that actual has keys.
    #
    # @param keys [Array] keys
    # @return [true] if assertion passes
    def has_key(*keys)
      matches(HasKey.new(*keys))
    end

    # Asserts that actual has values.
    #
    # @param values [Array] values
    # @return [true] if assertion passes
    def has_value(*values)
      matches(HasValue.new(*values))
    end

    # Asserts that actual contains items in any order.
    #
    # @param items [Array] items
    # @return [true] if assertion passes
    def contains(*items)
      matches(Contains.new(*items))
    end

    # Asserts that actual contains items in order.
    #
    # @param items [Array] items
    # @return [true] if assertion passes
    def contains_exactly(*items)
      matches(ContainsExactly.new(*items))
    end

    # Asserts that all items match.
    #
    # @param item_matcher [Matcher] matcher
    # @return [true] if assertion passes
    def all_items(item_matcher)
      matches(AllItems.new(item_matcher))
    end

    # Asserts that some items match.
    #
    # @param item_matcher [Matcher] matcher
    # @return [true] if assertion passes
    def some_items(item_matcher)
      matches(SomeItems.new(item_matcher))
    end

    # Asserts that no items match.
    #
    # @param item_matcher [Matcher] matcher
    # @return [true] if assertion passes
    def no_items(item_matcher)
      matches(NoItems.new(item_matcher))
    end

    # Asserts that all entries match.
    #
    # @param entry_matcher [Proc, Matcher] matcher
    # @return [true] if assertion passes
    def all_entries(entry_matcher)
      matches(AllEntries.new(entry_matcher))
    end

    # Asserts that at least one entry matches.
    #
    # @param entry_matcher [Proc, Matcher] matcher
    # @return [true] if assertion passes
    def some_entry(entry_matcher)
      matches(SomeEntry.new(entry_matcher))
    end

    # Asserts that no entries match.
    #
    # @param entry_matcher [Proc, Matcher] matcher
    # @return [true] if assertion passes
    def no_entry(entry_matcher)
      matches(NoEntry.new(entry_matcher))
    end

    # Asserts that actual is in collection.
    #
    # @param collection [Enumerable] collection
    # @return [true] if assertion passes
    def is_in(collection)
      matches(IsIn.new(collection))
    end

    # Asserts that actual has attribute.
    #
    # @param name [Symbol] attribute name
    # @param value_matcher [Matcher, nil] value matcher
    # @return [true] if assertion passes
    def has_attribute(name, value_matcher = nil)
      matches(HasAttribute.new(name, value_matcher))
    end

    # Asserts that actual does NOT match the given matcher.
    #
    # @param matcher [Matcher] the matcher that should not match
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if assertion fails
    #
    # @example
    #   assert_that(42).never(equals(0))
    #   assert_that(value).never(equals(nil))
    def never(matcher)
      matches(Not.new(matcher))
    end
    alias is_not never
    alias does_not never

    # Asserts that actual matches the given matcher.
    #
    # Use this for combined matchers or custom matchers.
    #
    # @param matcher [Matcher] the matcher to use
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if assertion fails
    #
    # @example With combined matchers
    #   assert_that(value).matches(equals(1) | equals(2))
    def matches(matcher)
      return true if matcher.matches?(@actual)

      failure_msg = matcher.failure_message(@actual)
      failure_msg = "#{@message}: #{failure_msg}" if @message

      raise Minitest::Assertion, failure_msg
    end

    # Asserts that the block raises an error.
    #
    # @param expected_class [Class, nil] optional error class to match
    # @param message_matcher [Matcher, nil] optional matcher for error message
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if assertion fails
    #
    # @example Any error
    #   assert_that { raise "boom" }.raises_error
    #
    # @example Specific error class
    #   assert_that { raise ArgumentError }.raises_error(ArgumentError)
    #
    # @example With message matcher
    #   assert_that { raise ArgumentError, "bad" }.raises_error(ArgumentError, includes("bad"))
    def raises_error(expected_class = nil, message_matcher = nil)
      raise ArgumentError, 'raises_error requires a block' unless @block

      begin
        @block.call
        # Block didn't raise - this is a failure
        failure_msg = if expected_class
                        "expected block to raise #{expected_class}, but no error was raised"
                      else
                        'expected block to raise an error, but no error was raised'
                      end
        failure_msg = "#{@message}: #{failure_msg}" if @message
        raise Minitest::Assertion, failure_msg
      rescue Minitest::Assertion
        raise
      rescue StandardError => e
        # Block raised an error - check if it matches expectations
        if expected_class && !e.is_a?(expected_class)
          failure_msg = "expected block to raise #{expected_class}, but raised #{e.class}: #{e.message}"
          failure_msg = "#{@message}: #{failure_msg}" if @message
          raise Minitest::Assertion, failure_msg
        end

        if message_matcher && !message_matcher.matches?(e.message)
          failure_msg = "expected block to raise #{expected_class || 'an error'} " \
                        "with message #{message_matcher.description}, but message was #{e.message.inspect}"
          failure_msg = "#{@message}: #{failure_msg}" if @message
          raise Minitest::Assertion, failure_msg
        end

        true
      end
    end

    # Asserts that the block does not raise any error.
    #
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if block raises an error
    #
    # @example
    #   assert_that { safe_operation }.raises_nothing
    def raises_nothing
      raise ArgumentError, 'raises_nothing requires a block' unless @block

      begin
        @block.call
        true
      rescue StandardError => e
        failure_msg = "expected block not to raise an error, but raised #{e.class}: #{e.message}"
        failure_msg = "#{@message}: #{failure_msg}" if @message
        raise Minitest::Assertion, failure_msg
      end
    end
  end
end
