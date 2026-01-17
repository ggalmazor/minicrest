# frozen_string_literal: true

require_relative 'comparison_matcher'

module Minicrest
  # Matcher that checks if a value is greater than or equal to an expected value.
  #
  # Works with any objects that support the >= operator.
  #
  # @example Basic usage
  #   is_greater_than_or_equal_to(5).matches?(10)  # => true
  #   is_greater_than_or_equal_to(5).matches?(5)   # => true
  #   is_greater_than_or_equal_to(5).matches?(3)   # => false
  # @see ComparisonMatcher
  class IsGreaterThanOrEqualTo < ComparisonMatcher
    # Creates a new greater-than-or-equal-to matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super(expected, :>=, 'greater than or equal to')
    end
  end
end
