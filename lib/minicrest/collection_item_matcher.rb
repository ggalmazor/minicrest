# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Base class for matchers that apply a matcher to items in a collection.
  #
  # @api private
  class CollectionItemMatcher < Matcher
    # Creates a new collection item matcher.
    #
    # @param item_matcher [Matcher] the matcher to apply to each item
    def initialize(item_matcher)
      super()
      @item_matcher = item_matcher
    end

    # Checks if actual is a collection.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual is enumerable
    def collection?(actual)
      actual.is_a?(Enumerable) || actual.respond_to?(:each)
    rescue NoMethodError
      false
    end

    protected

    # Returns the failure message from the item matcher, indented.
    #
    # @param item [Object] the item that failed
    # @return [String] indented failure message
    def item_failure_message(item)
      @item_matcher.failure_message(item).gsub(/^/, '  ')
    end
  end
end
