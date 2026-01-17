# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a string matches a regular expression.
  #
  # @example Basic usage
  #   matches_pattern(/\d+/).matches?("hello123")  # => true
  #   matches_pattern(/\d+/).matches?("hello")     # => false
  class MatchesPattern < Matcher
    # Creates a new pattern matcher.
    #
    # @param pattern [Regexp] the expected pattern
    def initialize(pattern)
      super()
      @pattern = pattern
    end

    # Checks if actual matches the expected pattern.
    #
    # @param actual [String] the string to check
    # @return [Boolean] true if actual matches pattern
    def matches?(actual)
      return false unless actual.respond_to?(:to_str)

      @pattern.match?(actual)
    rescue TypeError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected pattern
    def description
      "a string matching #{@pattern.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message showing expected pattern
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to match pattern #{@pattern.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message indicating unexpected pattern match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to match pattern #{@pattern.inspect}
        but it does
      MSG
    end
  end
end
