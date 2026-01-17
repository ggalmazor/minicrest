# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Base class for matchers that compare a value against an expected value using an operator.
  #
  # @api private
  class ComparisonMatcher < Matcher
    # Creates a new comparison matcher.
    #
    # @param expected [Object] the value to compare against
    # @param operator [Symbol] the comparison operator (e.g., :>, :<, :>=, :<=)
    # @param label [String] a human-readable label for the comparison (e.g., "greater than")
    def initialize(expected, operator, label)
      super()
      @expected = expected
      @operator = operator
      @label = label
    end

    # Checks if actual matches the expected value using the operator.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual.send(@operator, @expected)
    def matches?(actual)
      return false unless actual.respond_to?(@operator)

      actual.public_send(@operator, @expected)
    rescue ArgumentError, NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "#{@label} #{@expected.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      "expected #{actual.inspect} to be #{@label} #{@expected.inspect}"
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected comparison match
    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be #{@label} #{@expected.inspect}, but it was"
    end
  end
end
