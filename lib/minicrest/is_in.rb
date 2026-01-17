# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value is present in a collection.
  #
  # Works with:
  # - Arrays: checks if element is in array
  # - Hashes: checks if key is in hash
  # - Strings: checks if substring is in string
  # - Ranges: checks if value is in range
  #
  # @example With arrays
  #   is_in([1, 2, 3]).matches?(2)  # => true
  #
  # @example With hashes (checks keys)
  #   is_in({a: 1, b: 2}).matches?(:a)  # => true
  #
  # @example With strings
  #   is_in('hello').matches?('ell')  # => true
  #
  # @example With ranges
  #   is_in(1..10).matches?(5)  # => true
  class IsIn < Matcher
    # Creates a new is_in matcher.
    #
    # @param collection [Array, Hash, String, Range] the collection to check membership in
    def initialize(collection)
      super()
      @collection = collection
    end

    # Checks if actual is in the collection.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual is in the collection
    def matches?(actual)
      if @collection.is_a?(Hash)
        @collection.key?(actual)
      else
        @collection.include?(actual)
      end
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      "in #{format_collection(@collection)}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to be in #{format_collection(@collection)}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected membership
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to be in #{format_collection(@collection)}, but it was
      MSG
    end

    private

    def format_collection(collection)
      case collection
      when Hash
        "{#{collection.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}}"
      when Range
        collection.to_s
      else
        collection.inspect
      end
    end
  end
end
