# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value has a specific size.
  #
  # Works with any object that responds to `size`:
  # - Strings (character count)
  # - Arrays (element count)
  # - Hashes (key-value pair count)
  # - Sets (element count)
  #
  # Can be used with an integer for exact size matching,
  # or with another matcher for flexible size checking.
  #
  # @example Basic usage with integer
  #   has_size(5).matches?('hello')  # => true
  #   has_size(3).matches?([1, 2, 3])  # => true
  #   has_size(2).matches?({a: 1, b: 2})  # => true
  #
  # @example With matcher argument
  #   has_size(equals(5)).matches?('hello')  # => true
  #   has_size(never(equals(0))).matches?('hello')  # => true
  class HasSize < Matcher
    # Creates a new size matcher.
    #
    # @param expected [Integer, Matcher] the expected size or a matcher for the size
    def initialize(expected)
      super()
      @expected = expected
      @is_matcher = expected.is_a?(Matcher)
    end

    # Checks if actual has the expected size.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if size matches
    def matches?(actual)
      if @is_matcher
        @expected.matches?(actual.size)
      else
        actual.size == @expected
      end
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @is_matcher
        "has size #{@expected.description}"
      else
        "has size #{@expected}"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      if @is_matcher
        <<~MSG.chomp
          expected #{actual.inspect} to have size #{@expected.description}, but had size #{actual.size}
        MSG
      else
        <<~MSG.chomp
          expected #{actual.inspect} to have size #{@expected}, but had size #{actual.size}
        MSG
      end
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected size match
    def negated_failure_message(actual)
      if @is_matcher
        <<~MSG.chomp
          expected #{actual.inspect} not to have size #{@expected.description}, but it did
        MSG
      else
        <<~MSG.chomp
          expected #{actual.inspect} not to have size #{@expected}, but it did
        MSG
      end
    end
  end
end
