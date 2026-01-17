# frozen_string_literal: true

require_relative 'collection_item_matcher'

module Minicrest
  # Matcher that checks if all items in a collection match a given matcher.
  #
  # @example Basic usage
  #   all_items(descends_from(Integer)).matches?([1, 2, 3])  # => true
  #   all_items(descends_from(Integer)).matches?([1, 'two', 3])  # => false
  #
  # @example With comparison matchers
  #   all_items(is_greater_than(0)).matches?([1, 2, 3])  # => true
  # @see CollectionItemMatcher
  class AllItems < CollectionItemMatcher
    # Checks if all items match the item matcher.
    #
    # @param actual [Enumerable] the collection to check
    # @return [Boolean] true if all items match
    def matches?(actual)
      return false unless collection?(actual)

      actual.all? { |item| @item_matcher.matches?(item) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "all items are #{@item_matcher.description}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Enumerable] the collection that was checked
    # @return [String] failure message showing failing item
    def failure_message(actual)
      return "expected a collection, but got #{actual.inspect}" unless collection?(actual)

      failing_index = actual.find_index { |item| !@item_matcher.matches?(item) }
      failing_item = actual.to_a[failing_index]
      item_failure = item_failure_message(failing_item)

      <<~MSG.chomp
        expected all items to be #{@item_matcher.description}
        item at index #{failing_index} failed:
        #{item_failure}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param _actual [Enumerable] the collection that was checked
    # @return [String] message indicating unexpected match
    def negated_failure_message(_actual)
      <<~MSG.chomp
        expected not all items to be #{@item_matcher.description}, but they all matched
      MSG
    end
  end
end
