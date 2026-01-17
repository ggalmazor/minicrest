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
