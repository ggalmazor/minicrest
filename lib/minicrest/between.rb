# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Matcher that checks if a value is between a minimum and maximum.
  class Between < Matcher
    # Creates a new between matcher.
    #
    # @param min [Comparable] the minimum value
    # @param max [Comparable] the maximum value
    # @param exclusive [Boolean] whether the range is exclusive of min and max
    def initialize(min, max, exclusive: false)
      super()
      @min = min
      @max = max
      @exclusive = exclusive
    end

    # Checks if actual is between min and max.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if min <= actual <= max (or < if exclusive)
    def matches?(actual)
      return false unless actual.respond_to?(:>=) && actual.respond_to?(:<=)

      if @exclusive
        actual > @min && actual < @max
      else
        actual >= @min && actual <= @max
      end
    rescue ArgumentError, NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      range_type = @exclusive ? 'exclusively' : 'inclusively'
      "between #{@min.inspect} and #{@max.inspect} (#{range_type})"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      range_type = @exclusive ? 'exclusively' : 'inclusively'
      "expected #{actual.inspect} to be between #{@min.inspect} and #{@max.inspect} (#{range_type})"
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def negated_failure_message(actual)
      range_type = @exclusive ? 'exclusively' : 'inclusively'
      "expected #{actual.inspect} not to be between #{@min.inspect} and #{@max.inspect} (#{range_type}), but it was"
    end
  end
end
