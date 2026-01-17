# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a numeric value is within a delta of an expected value.
  #
  # Useful for floating-point comparisons where exact equality is unreliable.
  #
  # @example Basic usage
  #   is_close_to(3.14, 0.01).matches?(3.14159)  # => true
  #   is_close_to(3.14, 0.01).matches?(3.2)      # => false
  #
  # @example With integers
  #   is_close_to(100, 5).matches?(102)  # => true
  class IsCloseTo < Matcher
    # Creates a new close-to matcher.
    #
    # @param expected [Numeric] the expected value
    # @param delta [Numeric] the acceptable difference
    def initialize(expected, delta)
      super()
      @expected = expected
      @delta = delta
    end

    # Checks if actual is within delta of expected.
    #
    # @param actual [Numeric] the value to check
    # @return [Boolean] true if |actual - expected| <= delta
    def matches?(actual)
      (actual - @expected).abs <= @delta
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "close to #{@expected.inspect} (within #{@delta.inspect})"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Numeric] the value that was checked
    # @return [String] failure message showing actual difference
    def failure_message(actual)
      difference = (actual - @expected).abs
      <<~MSG.chomp
        expected #{actual.inspect} to be close to #{@expected.inspect} (within #{@delta.inspect}), but difference was #{difference.round(10)}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Numeric] the value that was checked
    # @return [String] message indicating unexpected closeness
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be close to #{@expected.inspect} (within #{@delta.inspect}), but it was
      MSG
    end
  end
end
