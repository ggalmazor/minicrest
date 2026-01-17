# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is greater than or equal to an expected value.
  #
  # Works with any objects that support the >= operator.
  #
  # @example Basic usage
  #   is_greater_than_or_equal_to(5).matches?(10)  # => true
  #   is_greater_than_or_equal_to(5).matches?(5)   # => true
  #   is_greater_than_or_equal_to(5).matches?(3)   # => false
  class IsGreaterThanOrEqualTo < Matcher
    # Creates a new greater-than-or-equal-to matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super()
      @expected = expected
    end

    # Checks if actual is greater than or equal to expected.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual >= expected
    def matches?(actual)
      actual >= @expected
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "greater than or equal to #{@expected.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to be greater than or equal to #{@expected.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected comparison
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be greater than or equal to #{@expected.inspect}, but it was
      MSG
    end
  end
end
