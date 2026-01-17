# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a hash contains specified keys.
  #
  # @example Single key
  #   has_key(:a).matches?({a: 1, b: 2})  # => true
  #
  # @example Multiple keys
  #   has_key(:a, :b).matches?({a: 1, b: 2, c: 3})  # => true
  class HasKey < Matcher
    # Creates a new has_key matcher.
    #
    # @param keys [Array<Symbol, String>] the keys that must be present
    def initialize(*keys)
      super()
      @keys = keys
    end

    # Checks if actual hash contains all expected keys.
    #
    # @param actual [Hash] the hash to check
    # @return [Boolean] true if all keys are present
    def matches?(actual)
      return false unless actual.respond_to?(:key?)

      @keys.all? { |key| actual.key?(key) }
    rescue NoMethodError
      false
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @keys.length == 1
        "has key #{@keys.first.inspect}"
      else
        "has keys #{@keys.map(&:inspect).join(', ')}"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Hash] the hash that was checked
    # @return [String] failure message listing missing keys
    def failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless actual.respond_to?(:key?)

      missing = @keys.reject { |key| actual.key?(key) }
      <<~MSG.chomp
        expected #{format_hash(actual)} to have keys #{@keys.map(&:inspect).join(', ')}
        missing: #{missing.map(&:inspect).join(', ')}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Hash] the hash that was checked
    # @return [String] message indicating unexpected key presence
    def negated_failure_message(actual)
      if @keys.length == 1
        <<~MSG.chomp
          expected #{format_hash(actual)} not to have key #{@keys.first.inspect}, but it did
        MSG
      else
        <<~MSG.chomp
          expected #{format_hash(actual)} not to have keys #{@keys.map(&:inspect).join(', ')}, but it did
        MSG
      end
    end

    private

    def format_hash(hash)
      "{#{hash.map { |k, v| "#{k}: #{v.inspect}" }.join(', ')}}"
    end
  end
end
