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
    # @param expected [Object, Matcher] the expected object reference or a matcher
    def initialize(expected)
      super()
      @expected = expected
    end

    # Checks if actual is the same object as expected, or matches if expected is a matcher.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual matches
    def matches?(actual)
      if @expected.is_a?(Matcher)
        @expected.matches?(actual)
      else
        actual.equal?(@expected)
      end
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @expected.is_a?(Matcher)
        @expected.description
      else
        "the same object as #{@expected.inspect} (object_id: #{@expected.object_id})"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      if @expected.is_a?(Matcher)
        @expected.failure_message(actual)
      else
        <<~MSG.chomp
          expected #{actual.inspect} (object_id: #{actual.object_id}) to be the same object as #{@expected.inspect} (object_id: #{@expected.object_id})
        MSG
      end
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def negated_failure_message(actual)
      if @expected.is_a?(Matcher)
        @expected.negated_failure_message(actual)
      else
        <<~MSG.chomp
          expected #{actual.inspect} (object_id: #{actual.object_id}) not to be the same object as #{@expected.inspect}, but they are the same object
        MSG
      end
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
