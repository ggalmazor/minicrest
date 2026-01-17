# frozen_string_literal: true

module Minicrest
  # Matcher that checks if at least one item in a collection matches a given matcher.
  #
  # @example Basic usage
  #   some_items(is_a(String)).matches?([1, 'two', 3])  # => true
  #   some_items(is_a(String)).matches?([1, 2, 3])  # => false
  class SomeItems < Matcher
    # Creates a new some_items matcher.
    #
    # @param item_matcher [Matcher] the matcher to apply to each item
    def initialize(item_matcher)
      super()
      @item_matcher = item_matcher
    end

    # Checks if at least one item matches the item matcher.
    #
    # @param actual [Array] the collection to check
    # @return [Boolean] true if any item matches
    def matches?(actual)
      actual.any? { |item| @item_matcher.matches?(item) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "some items are #{@item_matcher.description}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Array] the collection that was checked
    # @return [String] failure message
    def failure_message(_actual)
      <<~MSG.chomp
        expected some items to be #{@item_matcher.description}
        but no items matched
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Array] the collection that was checked
    # @return [String] message showing which item matched
    def negated_failure_message(actual)
      matching_index = actual.find_index { |item| @item_matcher.matches?(item) }
      matching_item = actual[matching_index]

      <<~MSG.chomp
        expected no items to be #{@item_matcher.description}
        but item at index #{matching_index} matched: #{matching_item.inspect}
      MSG
    end
  end
end
