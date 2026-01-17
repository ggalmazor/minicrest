# frozen_string_literal: true

module Minicrest
  # Matcher that checks if an array contains exactly the specified items in the specified order.
  #
  # @example
  #   contains_exactly(1, 2, 3).matches?([1, 2, 3])  # => true
  #   contains_exactly(1, 2, 3).matches?([3, 1, 2])  # => false (wrong order)
  #   contains_exactly(1, 2).matches?([1, 2, 3])     # => false (extra element)
  class ContainsExactly < Matcher
    # Creates a new contains_exactly matcher.
    #
    # @param items [Array] the items that must be contained in order
    def initialize(*items)
      super()
      @items = items
    end

    # Checks if actual contains exactly the expected items in order.
    #
    # @param actual [Array] the array to check
    # @return [Boolean] true if arrays are equal
    def matches?(actual)
      actual.to_a == @items
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "contains exactly #{@items.inspect} (in order)"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Array] the array that was checked
    # @return [String] failure message showing differences
    def failure_message(actual)
      actual_array = actual.to_a
      lines = ["expected #{actual.inspect} to contain exactly #{@items.inspect} (in order)"]

      if actual_array.length != @items.length
        lines << "expected size #{@items.length}, got #{actual_array.length}"
      else
        @items.each_with_index do |expected_item, index|
          actual_item = actual_array[index]
          if expected_item != actual_item
            lines << "at index #{index}: expected #{expected_item.inspect}, got #{actual_item.inspect}"
          end
        end
      end

      lines.join("\n")
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Array] the array that was checked
    # @return [String] message indicating unexpected match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to contain exactly #{@items.inspect} (in order), but it did
      MSG
    end
  end
end
