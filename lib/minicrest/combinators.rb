# frozen_string_literal: true

module Minicrest
  # Combinator that negates a matcher's result.
  #
  # Wraps another matcher and inverts its matching logic.
  # When the wrapped matcher succeeds, Not fails, and vice versa.
  #
  # @example Basic usage
  #   does_not(equals(5)).matches?(3) # => true (3 != 5)
  #   does_not(equals(5)).matches?(5) # => false (5 == 5)
  class Not < Matcher
    # Creates a new negating matcher.
    #
    # @param matcher [Matcher] the matcher to negate
    def initialize(matcher)
      super()
      @matcher = matcher
    end

    # Checks if actual does NOT match the wrapped matcher.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if the wrapped matcher returns false
    def matches?(actual)
      !@matcher.matches?(actual)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] negated description
    def description
      "not #{@matcher.description}"
    end

    # Returns the failure message when the negated match fails.
    #
    # This happens when the wrapped matcher succeeds (but we wanted it to fail).
    #
    # @param actual [Object] the value that was checked
    # @return [String] the wrapped matcher's negated failure message
    def failure_message(actual)
      @matcher.negated_failure_message(actual)
    end

    # Returns the failure message when a double-negated match fails.
    #
    # This happens when not(not(matcher)) is used and the inner matcher fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] the wrapped matcher's regular failure message
    def negated_failure_message(actual)
      @matcher.failure_message(actual)
    end
  end

  # Combinator that requires both matchers to succeed (logical AND).
  #
  # @example
  #   (greater_than(0) & less_than(10)).matches?(5) # => true
  #   (greater_than(0) & less_than(10)).matches?(15) # => false
  class And < Matcher
    # Creates a new AND combinator.
    #
    # @param left [Matcher] first matcher
    # @param right [Matcher] second matcher
    def initialize(left, right)
      super()
      @left = left
      @right = right
    end

    # Checks if actual matches both matchers.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if both matchers match
    def matches?(actual)
      @left.matches?(actual) && @right.matches?(actual)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] combined description
    def description
      "(#{@left.description} and #{@right.description})"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating which matcher(s) failed
    def failure_message(actual)
      messages = []
      messages << @left.failure_message(actual) unless @left.matches?(actual)
      messages << @right.failure_message(actual) unless @right.matches?(actual)
      messages.join("\n  AND\n")
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected match of both
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to match both conditions:
          #{@left.description}
          #{@right.description}
        but it matched both
      MSG
    end
  end

  # Combinator that requires at least one matcher to succeed (logical OR).
  #
  # @example
  #   (equals(1) | equals(2)).matches?(1) # => true
  #   (equals(1) | equals(2)).matches?(3) # => false
  class Or < Matcher
    # Creates a new OR combinator.
    #
    # @param left [Matcher] first matcher
    # @param right [Matcher] second matcher
    def initialize(left, right)
      super()
      @left = left
      @right = right
    end

    # Checks if actual matches at least one matcher.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if either matcher matches
    def matches?(actual)
      @left.matches?(actual) || @right.matches?(actual)
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] combined description
    def description
      "(#{@left.description} or #{@right.description})"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating neither matcher matched
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to match at least one of:
          #{@left.description}
          #{@right.description}
        but it matched neither:
          #{@left.failure_message(actual)}
          #{@right.failure_message(actual)}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating which matcher(s) matched
    def negated_failure_message(actual)
      matched = []
      matched << @left.description if @left.matches?(actual)
      matched << @right.description if @right.matches?(actual)

      <<~MSG.chomp
        expected #{actual.inspect} not to match either condition, but it matched:
          #{matched.join("\n  ")}
      MSG
    end
  end

  # Combinator that requires all matchers to succeed.
  #
  # @example
  #   all_of(equals(5), does_not(equal(nil))).matches?(5) # => true
  #   all_of(equals(5), equals(6)).matches?(5) # => false
  class All < Matcher
    # Creates a new ALL combinator.
    #
    # @param matchers [Array<Matcher>] matchers that must all match
    def initialize(*matchers)
      super()
      @matchers = matchers.flatten
    end

    # Checks if actual matches all matchers.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if all matchers match
    def matches?(actual)
      @matchers.all? { |m| m.matches?(actual) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] combined description
    def description
      "all of: #{@matchers.map(&:description).join(', ')}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating which matcher(s) failed
    def failure_message(actual)
      failed = @matchers.reject { |m| m.matches?(actual) }
      <<~MSG.chomp
        expected #{actual.inspect} to match all of:
          #{@matchers.map(&:description).join("\n  ")}
        but failed:
          #{failed.map { |m| m.failure_message(actual) }.join("\n  ")}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected match of all
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to match all conditions, but it matched all:
          #{@matchers.map(&:description).join("\n  ")}
      MSG
    end
  end

  # Combinator that requires none of the matchers to succeed.
  #
  # @example
  #   none_of(equals(5), equals(6)).matches?(7) # => true
  #   none_of(equals(5), equals(6)).matches?(5) # => false
  class None < Matcher
    # Creates a new NONE combinator.
    #
    # @param matchers [Array<Matcher>] matchers that must all fail
    def initialize(*matchers)
      super()
      @matchers = matchers.flatten
    end

    # Checks if actual matches none of the matchers.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if no matchers match
    def matches?(actual)
      @matchers.none? { |m| m.matches?(actual) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] combined description
    def description
      "none of: #{@matchers.map(&:description).join(', ')}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating which matcher(s) matched
    def failure_message(actual)
      matched = @matchers.select { |m| m.matches?(actual) }
      <<~MSG.chomp
        expected #{actual.inspect} to match none of:
          #{@matchers.map(&:description).join("\n  ")}
        but matched:
          #{matched.map(&:description).join("\n  ")}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating unexpected match of none
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to match at least one of:
          #{@matchers.map(&:description).join("\n  ")}
        but matched none
      MSG
    end
  end

  # Combinator that requires at least one matcher to succeed.
  #
  # @example
  #   some_of(equals(5), equals(6)).matches?(5) # => true
  #   some_of(equals(5), equals(6)).matches?(7) # => false
  class Some < Matcher
    # Creates a new SOME combinator.
    #
    # @param matchers [Array<Matcher>] matchers where at least one must match
    def initialize(*matchers)
      super()
      @matchers = matchers.flatten
    end

    # Checks if actual matches at least one matcher.
    #
    # @param actual [Object] the value to check
    # @return [Boolean] true if any matcher matches
    def matches?(actual)
      @matchers.any? { |m| m.matches?(actual) }
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] combined description
    def description
      "some of: #{@matchers.map(&:description).join(', ')}"
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating no matchers matched
    def failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to match at least one of:
          #{@matchers.map(&:description).join("\n  ")}
        but matched none:
          #{@matchers.map { |m| m.failure_message(actual) }.join("\n  ")}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the value that was checked
    # @return [String] message indicating which matcher(s) matched
    def negated_failure_message(actual)
      matched = @matchers.select { |m| m.matches?(actual) }
      <<~MSG.chomp
        expected #{actual.inspect} to match none of the conditions, but matched:
          #{matched.map(&:description).join("\n  ")}
      MSG
    end
  end
end
