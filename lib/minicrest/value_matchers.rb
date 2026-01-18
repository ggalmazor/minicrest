# frozen_string_literal: true

require_relative 'matcher'

module Minicrest
  # Matcher that checks if a value is nil.
  class NilValue < Matcher
    def matches?(actual)
      actual.nil?
    end

    def description
      'nil'
    end

    def failure_message(actual)
      "expected #{actual.inspect} to be nil"
    end

    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be nil, but it was"
    end
  end

  # Matcher that checks Ruby truthiness.
  class Truthy < Matcher
    def matches?(actual)
      !!actual
    end

    def description
      'truthy'
    end

    def failure_message(actual)
      "expected #{actual.inspect} to be truthy"
    end

    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be truthy, but it was"
    end
  end

  # Matcher that checks Ruby falsiness.
  class Falsy < Matcher
    def matches?(actual)
      !actual
    end

    def description
      'falsy'
    end

    def failure_message(actual)
      "expected #{actual.inspect} to be falsy"
    end

    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be falsy, but it was"
    end
  end

  # Matcher that checks for exact class membership.
  class InstanceOf < Matcher
    def initialize(expected_type)
      super()
      @expected_type = expected_type
    end

    def matches?(actual)
      actual.instance_of?(@expected_type)
    end

    def description
      "an instance of #{@expected_type}"
    end

    def failure_message(actual)
      "expected #{actual.inspect} to be an instance of #{@expected_type}, but was a #{actual.class}"
    end

    def negated_failure_message(actual)
      "expected #{actual.inspect} not to be an instance of #{@expected_type}, but it was"
    end
  end

  # Matcher that checks if a value is an instance of a given type.
  #
  # Uses Ruby's `is_a?` method which checks class hierarchy and module inclusion.
  #
  # @example Basic usage
  #   descends_from(String).matches?("hello")  # => true
  #   descends_from(Integer).matches?(42)      # => true
  #   descends_from(Enumerable).matches?([])   # => true (module inclusion)
  #
  # @example With inheritance
  #   descends_from(Exception).matches?(StandardError.new)  # => true (subclass)
  # @see InstanceOf
  class DescendsFrom < Matcher
    # Creates a new type matcher.
    #
    # @param expected_type [Class, Module] the expected type
    def initialize(expected_type)
      super()
      @expected_type = expected_type
    end

    # Checks if actual is an instance of the expected type.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if actual.is_a?(expected_type)
    def matches?(actual)
      actual.is_a?(@expected_type)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description of expected type
    def description
      "an instance of #{@expected_type}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message showing expected vs actual type
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              to be an instance of #{@expected_type}
        but was #{actual.class}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected type match
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect}
              not to be an instance of #{@expected_type}
        but it is
      MSG
    end
  end
end
