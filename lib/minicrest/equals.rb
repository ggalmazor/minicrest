# frozen_string_literal: true

module Minicrest
  # Matcher that checks for value equality using deep comparison.
  #
  # Uses Ruby's `==` operator which provides value equality semantics.
  # For data structures (Arrays, Hashes), this performs deep comparison
  # by value rather than by reference.
  #
  # @example Basic usage with primitives
  #   equals(42).matches?(42)     # => true
  #   equals("hello").matches?("hello") # => true
  #
  # @example Deep equality with arrays
  #   equals([1, 2, 3]).matches?([1, 2, 3]) # => true
  #   equals([1, [2, 3]]).matches?([1, [2, 3]]) # => true (nested)
  #
  # @example Deep equality with hashes
  #   equals({a: 1}).matches?({a: 1}) # => true
  #   equals({a: {b: 2}}).matches?({a: {b: 2}}) # => true (nested)
  class Equals < Matcher
    # Creates a new value equality matcher.
    #
    # @param expected [Object] the expected value
    def initialize(expected)
      super()
      @expected = expected
    end

    # Checks if actual equals expected by value.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual == expected
    def matches?(actual)
      actual == @expected
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected value
    def description
      "equal to #{@expected.inspect}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] detailed message showing both values
    def failure_message(actual)
      message = "expected #{actual.inspect}\n      " \
                "to equal #{@expected.inspect}"

      diff = compute_diff(actual)
      message += "\n\n#{diff}" if diff

      message
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected equality
    def negated_failure_message(actual)
      "expected #{actual.inspect}\n  " \
        "not to equal #{@expected.inspect}, but they are equal"
    end

    private

    # Computes a human-readable diff between actual and expected values.
    #
    # @param actual [Hash, Array, String] the actual value
    # @return [String, nil] diff string or nil if not applicable
    # noinspection RubyMismatchedArgumentType
    def compute_diff(actual)
      return nil unless diffable?(actual) && diffable?(@expected)

      if actual.is_a?(Hash) && @expected.is_a?(Hash)
        hash_diff(actual, @expected)
      elsif actual.is_a?(Array) && @expected.is_a?(Array)
        array_diff(actual, @expected)
      elsif actual.is_a?(String) && @expected.is_a?(String)
        string_diff(actual, @expected)
      end
    end

    # Checks if a value can be diffed.
    #
    # @param value [Object] the value to check
    # @return [Boolean] true if the value is diffable
    def diffable?(value)
      value.is_a?(Hash) || value.is_a?(Array) || value.is_a?(String)
    end

    # TODO: Replace with off-the-shelve gem
    # Computes diff for hashes.
    #
    # @param actual [Hash] actual hash
    # @param expected [Hash] expected hash
    # @return [String] diff description
    def hash_diff(actual, expected)
      missing_keys = expected.keys - actual.keys
      extra_keys = actual.keys - expected.keys
      common_keys = actual.keys & expected.keys

      lines = missing_keys.map do |key|
        "  missing key: #{key.inspect} => #{expected[key].inspect}"
      end

      extra_keys.each do |key|
        lines << "  extra key: #{key.inspect} => #{actual[key].inspect}"
      end

      common_keys.each do |key|
        next if actual[key] == expected[key]

        lines << "  key #{key.inspect}:"
        lines << "    expected: #{expected[key].inspect}"
        lines << "    actual:   #{actual[key].inspect}"
      end

      return nil if lines.empty?

      "Diff:\n#{lines.join("\n")}"
    end

    # TODO: Replace with off-the-shelve gem
    # Computes diff for arrays.
    #
    # @param actual [Array] actual array
    # @param expected [Array] expected array
    # @return [String] diff description
    def array_diff(actual, expected)
      lines = []

      lines << "  size mismatch: expected #{expected.size} elements, got #{actual.size}" if actual.size != expected.size

      max_index = [actual.size, expected.size].max
      max_index.times do |i|
        if i >= actual.size
          lines << "  missing [#{i}]: #{expected[i].inspect}"
        elsif i >= expected.size
          lines << "  extra [#{i}]: #{actual[i].inspect}"
        elsif actual[i] != expected[i]
          lines << "  [#{i}]:"
          lines << "    expected: #{expected[i].inspect}"
          lines << "    actual:   #{actual[i].inspect}"
        end
      end

      return nil if lines.empty?

      "Diff:\n#{lines.join("\n")}"
    end

    # Computes diff for strings.
    #
    # @param actual [String] actual string
    # @param expected [String] expected string
    # @return [String] diff description
    def string_diff(actual, expected)
      return nil if actual.length < 20 && expected.length < 20

      lines = []

      if actual.length != expected.length
        lines << "  length mismatch: expected #{expected.length} chars, got #{actual.length}"
      end

      # Find first difference
      first_diff = actual.chars.zip(expected.chars).find_index { |a, e| a != e }
      if first_diff
        context_start = [0, first_diff - 10].max
        context_end = [actual.length, expected.length, first_diff + 10].min

        lines << "  first difference at position #{first_diff}:"
        lines << "    expected: ...#{expected[context_start..context_end].inspect}..."
        lines << "    actual:   ...#{actual[context_start..context_end].inspect}..."
      end

      return nil if lines.empty?

      "Diff:\n#{lines.join("\n")}"
    end
  end

  # Factory method to create an Equals matcher.
  #
  # @param expected [Object] the expected value
  # @return [Equals] a new value equality matcher
  #
  # @example
  #   assert_that result, equals(42)
  #   assert_that data, equals({name: "test", value: 123})
  def equals(expected)
    Equals.new(expected)
  end
  module_function :equals
end
