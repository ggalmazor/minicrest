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
  class Asserter
    # Creates a new asserter for the given value.
    #
    # @param actual [Object] the value to assert against
    # @param message [String, nil] optional message prefix for failures
    def initialize(actual, message = nil)
      @actual = actual
      @message = message
    end

    # Asserts that actual equals expected by value (deep equality).
    #
    # @param expected [Object] the expected value
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if assertion fails
    #
    # @example
    #   assert_that(42).equals(42)
    #   assert_that([1, 2]).equals([1, 2])
    def equals(expected)
      matches(Equals.new(expected))
    end

    # Asserts that actual is the same object as expected (reference equality).
    #
    # @param expected [Object] the expected object reference
    # @return [true] if assertion passes
    # @raise [Minitest::Assertion] if assertion fails
    #
    # @example
    #   obj = Object.new
    #   assert_that(obj).is(obj)
    def is(expected)
      matches(Is.new(expected))
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
  end
end
