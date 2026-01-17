# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value includes specified items.
  #
  # Works with:
  # - Strings: checks for substrings
  # - Arrays: checks for elements
  # - Hashes: checks for key-value pairs
  #
  # @example With strings
  #   includes('hello', 'world').matches?('hello world')  # => true
  #
  # @example With arrays
  #   includes(1, 3).matches?([1, 2, 3])  # => true
  #
  # @example With hashes
  #   includes(a: 1).matches?({a: 1, b: 2})  # => true
  class Includes < Matcher
    # Creates a new includes matcher.
    #
    # @param items [Array] the items that must be included
    def initialize(*items)
      super()
      @items = items
      @is_hash = items.length == 1 && items.first.is_a?(Hash)
      @expected_hash = @is_hash ? items.first : nil
    end

    # Checks if actual includes all expected items.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if all items are included
    def matches?(actual)
      if @is_hash && actual.is_a?(Hash)
        @expected_hash.all? { |k, v| actual[k] == v }
      elsif actual.is_a?(Hash)
        @items.all? { |item| item.is_a?(Hash) ? item.all? { |k, v| actual[k] == v } : actual.include?(item) }
      else
        @items.all? { |item| actual.include?(item) }
      end
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @is_hash
        "includes #{format_hash(@expected_hash)}"
      else
        "includes #{@items.map(&:inspect).join(', ')}"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] failure message listing missing items
    def failure_message(actual)
      missing = find_missing(actual)
      if @is_hash
        <<~MSG.chomp
          expected #{format_value(actual)} to include #{format_hash(@expected_hash)}
          missing: #{format_hash(missing)}
        MSG
      else
        <<~MSG.chomp
          expected #{format_value(actual)} to include #{@items.map(&:inspect).join(', ')}
          missing: #{missing.map(&:inspect).join(', ')}
        MSG
      end
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected inclusion
    def negated_failure_message(actual)
      if @is_hash
        <<~MSG.chomp
          expected #{format_value(actual)} not to include #{format_hash(@expected_hash)}, but it did
        MSG
      else
        <<~MSG.chomp
          expected #{format_value(actual)} not to include #{@items.map(&:inspect).join(', ')}, but it did
        MSG
      end
    end

    private

    def find_missing(actual)
      if @is_hash && actual.is_a?(Hash)
        @expected_hash.reject { |k, v| actual[k] == v }
      elsif actual.is_a?(Hash)
        @items.reject { |item| item.is_a?(Hash) ? item.all? { |k, v| actual[k] == v } : actual.include?(item) }
      else
        @items.reject { |item| actual.include?(item) }
      end
    end

    def format_value(value)
      if value.is_a?(Hash)
        format_hash(value)
      else
        value.inspect
      end
    end

    def format_hash(hash)
      "{#{hash.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}}"
    end
  end
end
