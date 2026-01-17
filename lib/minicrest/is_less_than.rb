# frozen_string_literal: true

require_relative 'comparison_matcher'

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
  # @see ComparisonMatcher
  class IsLessThan < ComparisonMatcher
    # Creates a new less-than matcher.
    #
    # @param expected [Comparable] the value to compare against
    def initialize(expected)
      super(expected, :<, 'less than')
    end
  end
end
