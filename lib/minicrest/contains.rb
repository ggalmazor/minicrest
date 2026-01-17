# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a collection contains exactly the specified items in any order.
  #
  # For arrays: checks that the array has exactly the specified elements (order doesn't matter)
  # For hashes: checks that the hash has exactly the specified key-value pairs
  #
  # @example With arrays
  #   contains(1, 2, 3).matches?([3, 1, 2])  # => true
  #   contains(1, 2).matches?([1, 2, 3])      # => false (extra element)
  #
  # @example With hashes
  #   contains(a: 1, b: 2).matches?({b: 2, a: 1})  # => true
  class Contains < Matcher
    # Creates a new contains matcher.
    #
    # @param items [Array] the items that must be contained (and no others)
    def initialize(*items)
      super()
      @items = items
      @is_hash = items.length == 1 && items.first.is_a?(Hash)
      @expected_hash = @is_hash ? items.first : nil
    end

    # Checks if actual contains exactly the expected items.
    #
    # @param actual [Array, Hash] the collection to check
    # @return [Boolean] true if collections have same items
    def matches?(actual)
      if @is_hash && actual.is_a?(Hash)
        actual == @expected_hash
      elsif actual.is_a?(Hash)
        false # Can't compare non-hash items to hash
      else
        actual.sort == @items.sort
      end
    rescue ArgumentError
      # Sort may fail for uncomparable items, fall back to counting
      count_match?(actual)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @is_hash
        "contains exactly #{format_hash(@expected_hash)} (in any order)"
      else
        "contains exactly #{@items.map(&:inspect).join(', ')} (in any order)"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Array, Hash] the collection that was checked
    # @return [String] failure message showing differences
    def failure_message(actual)
      if @is_hash && actual.is_a?(Hash)
        missing = @expected_hash.reject { |k, v| actual[k] == v }
        extra = actual.reject { |k, v| @expected_hash[k] == v }
        build_hash_failure_message(actual, missing, extra)
      else
        missing = @items - actual.to_a
        extra = actual.to_a - @items
        build_array_failure_message(actual, missing, extra)
      end
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Array, Hash] the collection that was checked
    # @return [String] message indicating unexpected match
    def negated_failure_message(actual)
      if @is_hash
        <<~MSG.chomp
          expected #{format_hash(actual)} not to contain exactly #{format_hash(@expected_hash)} (in any order), but it did
        MSG
      else
        <<~MSG.chomp
          expected #{actual.inspect} not to contain exactly #{@items.map(&:inspect).join(', ')} (in any order), but it did
        MSG
      end
    end

    private

    def count_match?(actual)
      return false unless actual.length == @items.length

      actual_counts = actual.each_with_object(Hash.new(0)) { |item, h| h[item] += 1 }
      expected_counts = @items.each_with_object(Hash.new(0)) { |item, h| h[item] += 1 }
      actual_counts == expected_counts
    end

    def build_array_failure_message(actual, missing, extra)
      lines = ["expected #{actual.inspect} to contain exactly #{@items.map(&:inspect).join(', ')} (in any order)"]
      lines << "missing: #{missing.map(&:inspect).join(', ')}" unless missing.empty?
      lines << "extra: #{extra.map(&:inspect).join(', ')}" unless extra.empty?
      lines.join("\n")
    end

    def build_hash_failure_message(actual, missing, extra)
      lines = ["expected #{format_hash(actual)} to contain exactly #{format_hash(@expected_hash)} (in any order)"]
      lines << "missing: #{format_hash(missing)}" unless missing.empty?
      lines << "extra: #{format_hash(extra)}" unless extra.empty?
      lines.join("\n")
    end

    def format_hash(hash)
      "{#{hash.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}}"
    end
  end
end
