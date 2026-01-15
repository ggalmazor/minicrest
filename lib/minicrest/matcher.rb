# frozen_string_literal: true

module Minicrest
  # Base class for all matchers.
  #
  # Matchers encapsulate a matching condition and provide descriptive
  # messages for both successful and failed matches.
  #
  # To create a custom matcher, subclass this and implement:
  # - #matches?(actual) - returns true if the actual value matches
  # - #description - returns a description of what the matcher expects
  # - #failure_message(actual) - returns message when match fails
  # - #negated_failure_message(actual) - returns message when negated match fails
  #
  # @example Creating a custom matcher
  #   class GreaterThan < Matcher
  #     def initialize(expected)
  #       @expected = expected
  #     end
  #
  #     def matches?(actual)
  #       actual > @expected
  #     end
  #
  #     def description
  #       "a value greater than #{@expected.inspect}"
  #     end
  #
  #     def failure_message(actual)
  #       "expected #{actual.inspect} to be greater than #{@expected.inspect}"
  #     end
  #
  #     def negated_failure_message(actual)
  #       "expected #{actual.inspect} not to be greater than #{@expected.inspect}"
  #     end
  #   end
  class Matcher
    # Checks if the actual value matches this matcher's condition.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if the value matches
    def matches?(actual)
      raise NotImplementedError, "#{self.class} must implement #matches?"
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] human-readable description
    def description
      raise NotImplementedError, "#{self.class} must implement #description"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] human-readable failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to be #{description}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] human-readable failure message for negated case
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to be #{description}
      MSG
    end

    # Combines this matcher with another using logical AND.
    #
    # @param other [Matcher] another matcher
    # @return [And] a combined matcher that requires both to match
    def &(other)
      And.new(self, other)
    end

    # Combines this matcher with another using logical OR.
    #
    # @param other [Matcher] another matcher
    # @return [Or] a combined matcher that requires either to match
    def |(other)
      Or.new(self, other)
    end
  end
end
