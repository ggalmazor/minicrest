# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a string starts with a given prefix.
  #
  # @example Basic usage
  #   starts_with("hello").matches?("hello world")  # => true
  #   starts_with("world").matches?("hello world")  # => false
  class StartsWith < Matcher
    # Creates a new starts_with matcher.
    #
    # @param prefix [String] the expected prefix
    def initialize(prefix)
      super()
      @prefix = prefix
    end

    # Checks if actual starts with the expected prefix.
    #
    # @param actual [String] the string to check
    # @return [Boolean] true if actual starts with prefix
    def matches?(actual)
      actual.start_with?(@prefix)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected prefix
    def description
      "a string starting with #{@prefix.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message showing expected prefix
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to start with #{@prefix.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message indicating unexpected prefix match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to start with #{@prefix.inspect}
        but it does
      MSG
    end
  end
end
