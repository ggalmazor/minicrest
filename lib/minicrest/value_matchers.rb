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
end
