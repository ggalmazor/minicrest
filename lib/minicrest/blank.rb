# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a string is blank (empty or whitespace-only).
  #
  # @example Basic usage
  #   blank.matches?("")      # => true
  #   blank.matches?("   ")   # => true
  #   blank.matches?("hello") # => false
  class Blank < Matcher
    # Checks if actual is a blank string.
    #
    # @param actual [String] the string to check
    # @return [Boolean] true if actual is empty or whitespace-only
    def matches?(actual)
      return false unless actual.respond_to?(:strip)

      actual.strip.empty?
    rescue NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of blank expectation
    def description
      'a blank string'
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message showing expected blank
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to be blank
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [String] the string that was checked
    # @return [String] message indicating unexpected blank match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to be blank
        but it is
      MSG
    end
  end
end
