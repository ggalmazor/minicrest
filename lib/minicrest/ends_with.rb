# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a string ends with a given suffix.
  #
  # @example Basic usage
  #   ends_with("world").matches?("hello world")  # => true
  #   ends_with("hello").matches?("hello world")  # => false
  class EndsWith < Matcher
    # Creates a new ends_with matcher.
    #
    # @param suffix [String] the expected suffix
    def initialize(suffix)
      super()
      @suffix = suffix
    end

    # Checks if actual ends with the expected suffix.
    #
    # @param actual [String] the string to check
    # @return [Boolean] true if actual ends with suffix
    def matches?(actual)
      actual.end_with?(@suffix)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected suffix
    def description
      "a string ending with #{@suffix.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message showing expected suffix
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to end with #{@suffix.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message indicating unexpected suffix match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to end with #{@suffix.inspect}
        but it does
      MSG
    end
  end
end
