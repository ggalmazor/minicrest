# frozen_string_literal: true

module Minicrest
  # Matcher that matches any value (placeholder matcher).
  #
  # Use this when you want to assert the structure of data but don't
  # care about specific values, or when testing that something exists
  # without caring what it is.
  #
  # @example Basic usage
  #   anything.matches?(42)      # => true
  #   anything.matches?(nil)     # => true
  #   anything.matches?("hello") # => true
  #
  # @example With complex structures (partial matching)
  #   # When combined with other matchers for partial assertions
  #   assert_that(result).matches(anything)
  class Anything < Matcher
    # Matches any value.
    #
    # @param _actual [Object] the value to check (ignored)
    # @return [Boolean] always true
    def matches?(_actual)
      true
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      'anything'
    end

    # Returns the failure message when the match fails.
    #
    # Note: This method should never be called since anything always matches.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      "expected #{actual.inspect} to be anything (this should never fail)"
    end

    # Returns the failure message when a negated match fails.
    #
    # This is called when does_not(anything) fails because anything matched.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected match
    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be anything, but everything is something"
    end
  end
end
