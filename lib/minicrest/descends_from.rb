# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is an instance of a given type.
  #
  # Uses Ruby's `is_a?` method which checks class hierarchy and module inclusion.
  #
  # @example Basic usage
  #   descends_from(String).matches?("hello")  # => true
  #   descends_from(Integer).matches?(42)      # => true
  #   descends_from(Enumerable).matches?([])   # => true (module inclusion)
  #
  # @example With inheritance
  #   descends_from(Exception).matches?(StandardError.new)  # => true (subclass)
  # @see InstanceOf
  class DescendsFrom < Matcher
    # Creates a new type matcher.
    #
    # @param expected_type [Class, Module] the expected type
    def initialize(expected_type)
      super()
      @expected_type = expected_type
    end

    # Checks if actual is an instance of the expected type.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual.is_a?(expected_type)
    def matches?(actual)
      actual.is_a?(@expected_type)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected type
    def description
      "an instance of #{@expected_type}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message showing expected vs actual type
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to be an instance of #{@expected_type}
        but was #{actual.class}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected type match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to be an instance of #{@expected_type}
        but it is
      MSG
    end
  end
end
