# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Base class for matchers that check string properties.
  #
  # @api private
  class StringMatcher < Matcher
    # Creates a new string matcher.
    #
    # @param substring [String] the expected substring
    # @param method [Symbol] the method to call on the string (:start_with?, :end_with?)
    # @param label [String] a human-readable label (e.g., "start with")
    def initialize(substring, method, label)
      super()
      @substring = substring
      @method = method
      @label = label
    end

    # Checks if actual matches the condition.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual matches
    def matches?(actual)
      return false unless actual.respond_to?(@method)

      actual.public_send(@method, @substring)
    rescue ArgumentError, NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "a string #{@label} #{@substring.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to #{@label} #{@substring.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to #{@label} #{@substring.inspect}
        but it does
      MSG
    end
  end
end
