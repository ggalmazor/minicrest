# frozen_string_literal: true

module Minicrest
  # Matcher that checks for reference equality (same object identity).
  #
  # Uses Ruby's `equal?` method which checks if two references point
  # to the exact same object in memory.
  #
  # @example Basic usage
  #   obj = Object.new
  #   same_ref = obj
  #   different_obj = Object.new
  #
  #   is(obj).matches?(same_ref)      # => true
  #   is(obj).matches?(different_obj) # => false
  #
  # @example With strings (reference vs value)
  #   str = "hello"
  #   is(str).matches?(str)       # => true (same reference)
  #   is(str).matches?("hello")   # => false (different object, same value)
  class Is < Matcher
    # Creates a new reference equality matcher.
    #
    # @param expected [Object] the expected object reference (must not be a Matcher)
    # @raise [ArgumentError] if expected is a Matcher
    def initialize(expected)
      super()
      if expected.is_a?(Matcher)
        raise ArgumentError,
              'is() expects a value, not a matcher. ' \
              'Use is() for reference equality checks, ' \
              'or use matches() with the matcher directly.'
      end
      @expected = expected
    end

    # Checks if actual is the same object as expected.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual.equal?(expected)
    def matches?(actual)
      actual.equal?(@expected)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description including object id
    def description
      "the same object as #{@expected.inspect} (object_id: #{@expected.object_id})"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] detailed message showing both object ids
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} (object_id: #{actual.object_id}) to be the same object as #{@expected.inspect} (object_id: #{@expected.object_id})
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected reference equality
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} (object_id: #{actual.object_id}) not to be the same object as #{@expected.inspect}, but they are the same object
      MSG
    end
  end

  # Factory method to create an Is matcher.
  #
  # @param expected [Object] the expected object reference
  # @return [Is] a new reference equality matcher
  #
  # @example
  #   assert_that obj, is(same_obj)
  def is(expected)
    Is.new(expected)
  end
  module_function :is
end
