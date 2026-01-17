# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is empty.
  #
  # Works with any object that responds to `empty?`:
  # - Strings
  # - Arrays
  # - Hashes
  # - Sets
  # - Any Enumerable
  #
  # @example Basic usage
  #   empty.matches?('')     # => true
  #   empty.matches?([])     # => true
  #   empty.matches?({})     # => true
  #   empty.matches?('hi')   # => false
  #   empty.matches?([1])    # => false
  class Empty < Matcher
    # Checks if actual is empty.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual.empty?
    def matches?(actual)
      actual.empty?
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      'empty'
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to be empty, but had size #{actual.size}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected emptiness
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be empty, but it was
      MSG
    end
  end
end
