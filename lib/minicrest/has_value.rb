# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a hash contains specified values.
  #
  # @example Single value
  #   has_value(1).matches?({a: 1, b: 2})  # => true
  #
  # @example Multiple values
  #   has_value(1, 2).matches?({a: 1, b: 2, c: 3})  # => true
  class HasValue < Matcher
    # Creates a new has_value matcher.
    #
    # @param values [Array] the values that must be present
    def initialize(*values)
      super()
      @values = values
    end

    # Checks if actual hash contains all expected values.
    #
    # @param actual [Hash] the hash to check
    # @return [Boolean] true if all values are present
    def matches?(actual)
      return false unless actual.respond_to?(:value?)

      @values.all? { |value| actual.value?(value) }
    rescue NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @values.length == 1
        "has value #{@values.first.inspect}"
      else
        "has values #{@values.map(&:inspect).join(', ')}"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Hash] the hash that was checked
    # @return [String] failure message listing missing values
    def failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless actual.respond_to?(:value?)

      missing = @values.reject { |value| actual.value?(value) }
      <<~MSG.chomp
        expected #{format_hash(actual)} to have values #{@values.map(&:inspect).join(', ')}
        missing: #{missing.map(&:inspect).join(', ')}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Hash] the hash that was checked
    # @return [String] message indicating unexpected value presence
    def negated_failure_message(actual)
      if @values.length == 1
        <<~MSG.chomp
          expected #{format_hash(actual)} not to have value #{@values.first.inspect}, but it did
        MSG
      else
        <<~MSG.chomp
          expected #{format_hash(actual)} not to have values #{@values.map(&:inspect).join(', ')}, but it did
        MSG
      end
    end

    private

    def format_hash(hash)
      "{#{hash.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}}"
    end
  end
end
