# frozen_string_literal: true

require_relative 'collection_item_matcher'

module Minicrest
  # Matcher that checks if at least one item in a collection matches a given matcher.
  #
  # @example Basic usage
  #   some_items(descends_from(String)).matches?([1, 'two', 3])  # => true
  #   some_items(descends_from(String)).matches?([1, 2, 3])  # => false
  # @see CollectionItemMatcher
  class SomeItems < CollectionItemMatcher
    # Checks if at least one item matches the item matcher.
    #
    # @param actual [Enumerable] the collection to check
    # @return [Boolean] true if any item matches
    def matches?(actual)
      return false unless collection?(actual)

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
    # @param actual [Enumerable] the collection that was checked
    # @return [String] failure message
    def failure_message(actual)
      return "expected a collection, but got #{actual.inspect}" unless collection?(actual)

      <<~MSG.chomp
        expected some items to be #{@item_matcher.description}
        but no items matched
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Enumerable] the collection that was checked
    # @return [String] message showing which item matched
    def negated_failure_message(actual)
      return "expected a collection, but got #{actual.inspect}" unless collection?(actual)

      matching_index = actual.find_index { |item| @item_matcher.matches?(item) }
      matching_item = actual.to_a[matching_index]

      <<~MSG.chomp
        expected no items to be #{@item_matcher.description}
        but item at index #{matching_index} matched: #{matching_item.inspect}
      MSG
    end
  end
end
