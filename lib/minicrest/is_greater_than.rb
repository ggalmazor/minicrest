# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is greater than an expected value.
  #
  # Works with any objects that support the > operator.
  #
  # @example Basic usage
  #   is_greater_than(5).matches?(10)   # => true
  #   is_greater_than(5).matches?(5)    # => false
  #   is_greater_than(5).matches?(3)    # => false
  #
  # @example With floats
  #   is_greater_than(3.14).matches?(3.15)  # => true
  #
  # @example Combined for range checking
  #   in_range = is_greater_than(0) & is_less_than(10)
  #   in_range.matches?(5)  # => true
  class IsGreaterThan < Matcher
    # Creates a new greater-than matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super()
      @expected = expected
    end

    # Checks if actual is greater than expected.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual > expected
    def matches?(actual)
      actual > @expected
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "greater than #{@expected.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to be greater than #{@expected.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected greater-than
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be greater than #{@expected.inspect}, but it was
      MSG
    end
  end
end
