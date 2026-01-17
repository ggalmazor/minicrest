# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Base class for matchers that check entries in a Hash.
  #
  # @api private
  class HashEntryMatcher < Matcher
    # Creates a new hash entry matcher.
    #
    # @param entry_matcher [Proc, Matcher] a proc or matcher that receives (key, value)
    def initialize(entry_matcher)
      super()
      @entry_matcher = entry_matcher
    end

    # Checks if actual is a Hash.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual is a Hash
    def hash?(actual)
      actual.is_a?(Hash)
    end

    protected

    # Checks if an entry matches the entry matcher.
    #
    # @param key [Object] the entry key
    # @param value [Object] the entry value
    # @return [Boolean] true if the entry matches
    def entry_matches?(key, value)
      if @entry_matcher.respond_to?(:call)
        @entry_matcher.call(key, value)
      elsif @entry_matcher.respond_to?(:matches?)
        @entry_matcher.matches?([key, value])
      else
        false
      end
    end
  end

  # Matcher that checks if all entries in a hash match a given condition.
  class AllEntries < HashEntryMatcher
    def matches?(actual)
      return false unless hash?(actual)

      actual.all? { |k, v| entry_matches?(k, v) }
    end

    def description
      'all entries match condition'
    end

    def failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless hash?(actual)

      failing_entry = actual.find { |k, v| !entry_matches?(k, v) }
      "expected all entries to match, but entry #{failing_entry.inspect} did not"
    end

    def negated_failure_message(_actual)
      'expected not all entries to match, but they all did'
    end
  end

  # Matcher that checks if at least one entry in a hash matches a given condition.
  class SomeEntry < HashEntryMatcher
    def matches?(actual)
      return false unless hash?(actual)

      actual.any? { |k, v| entry_matches?(k, v) }
    end

    def description
      'at least one entry matches condition'
    end

    def failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless hash?(actual)

      'expected at least one entry to match, but none did'
    end

    def negated_failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless hash?(actual)

      matching_entry = actual.find { |k, v| entry_matches?(k, v) }
      "expected no entries to match, but entry #{matching_entry.inspect} did"
    end
  end

  # Matcher that checks if no entries in a hash match a given condition.
  class NoEntry < HashEntryMatcher
    def matches?(actual)
      return false unless hash?(actual)

      actual.none? { |k, v| entry_matches?(k, v) }
    end

    def description
      'no entries match condition'
    end

    def failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless hash?(actual)

      matching_entry = actual.find { |k, v| entry_matches?(k, v) }
      "expected no entries to match, but entry #{matching_entry.inspect} did"
    end

    def negated_failure_message(actual)
      return "expected a Hash, but got #{actual.inspect}" unless hash?(actual)

      'expected some entries to match, but none did'
    end
  end
end
