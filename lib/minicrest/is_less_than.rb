# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is less than an expected value.
  #
  # Works with any objects that support the < operator.
  #
  # @example Basic usage
  #   is_less_than(5).matches?(3)    # => true
  #   is_less_than(5).matches?(5)    # => false
  #   is_less_than(5).matches?(10)   # => false
  #
  # @example With floats
  #   is_less_than(3.14).matches?(3.13)  # => true
  #
  # @example Combined for range checking
  #   in_range = is_greater_than(0) & is_less_than(10)
  #   in_range.matches?(5)  # => true
  class IsLessThan < Matcher
    # Creates a new less-than matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super()
      @expected = expected
    end

    # Checks if actual is less than expected.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual < expected
    def matches?(actual)
      actual < @expected
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "less than #{@expected.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to be less than #{@expected.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected less-than
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be less than #{@expected.inspect}, but it was
      MSG
    end
  end
end
