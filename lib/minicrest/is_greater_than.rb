# frozen_string_literal: true

require_relative 'comparison_matcher'

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
  # @see ComparisonMatcher
  class IsGreaterThan < ComparisonMatcher
    # Creates a new greater-than matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super(expected, :>, 'greater than')
    end
  end
end
