# frozen_string_literal: true

module Minicrest
  # Matcher that checks if a value responds to specified methods.
  #
  # Uses Ruby's `respond_to?` method to check method availability.
  #
  # @example Single method
  #   responds_to(:upcase).matches?("hello")  # => true
  #
  # @example Multiple methods
  #   responds_to(:push, :pop).matches?([])   # => true
  class RespondsTo < Matcher
    # Creates a new responds_to matcher.
    #
    # @param methods [Array<Symbol>] the methods to check for
    def initialize(*methods)
      super()
      @methods = methods.flatten
    end

    # Checks if actual responds to all specified methods.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual responds to all methods
    def matches?(actual)
      @methods.all? { |method| actual.respond_to?(method) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected methods
    def description
      "respond to #{@methods.map(&:inspect).join(', ')}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message showing missing methods
    def failure_message(actual)
      missing = @methods.reject { |method| actual.respond_to?(method) }
      <<~MSG.chomp
        expected #{actual.inspect}
              to respond to #{@methods.map(&:inspect).join(', ')}
        missing: #{missing.map(&:inspect).join(', ')}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected method availability
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to respond to #{@methods.map(&:inspect).join(', ')}
        but it does
      MSG
    end
  end
end
