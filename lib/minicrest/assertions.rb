# frozen_string_literal: true

module Minicrest
  # Assertions module that provides Hamcrest-style assert_that with fluent API.
  #
  # Include this module in your test class or Minitest::Test to get
  # access to the assert_that fluent assertion and matcher factory methods.
  #
  # @example Including in a test class
  #   class MyTest < Minitest::Test
  #     include Minicrest::Assertions
  #
  #     def test_something
  #       assert_that(42).equals(42)
  #     end
  #   end
  module Assertions
    # Creates a fluent asserter for the given value.
    #
    # This is the main entry point for Hamcrest-style assertions.
    # Returns an Asserter that provides chainable matcher methods.
    #
    # @param actual [Object] the value to check
    # @param message [String, nil] optional custom message prefix
    # @return [Asserter] fluent asserter for chaining
    #
    # @example Basic assertions
    #   assert_that(42).equals(42)
    #   assert_that(obj).is(same_obj)
    #   assert_that(value).is_not(equals(nil))
    #
    # @example With combined matchers
    #   assert_that(value).matches(equals(1) | equals(2))
    #   assert_that(value).matches(is_not(equals(nil)) & is_not(equals("")))
    #
    # @example With custom message
    #   assert_that(result, "computation result").equals(expected)
    def assert_that(actual, message = nil)
      Asserter.new(actual, message)
    end

    # Factory method for equals() matcher.
    #
    # @param expected [Object] the expected value
    # @return [Equals] value equality matcher
    def equals(expected)
      Minicrest::Equals.new(expected)
    end

    # Factory method for anything() placeholder matcher.
    #
    # Use this when you want to assert the structure of data but don't
    # care about specific values, or when testing that something exists
    # without caring what it is.
    #
    # @return [Anything] matcher that matches any value
    #
    # @example Basic usage
    #   assert_that(value).matches(anything)
    #
    # @example With negation (unusual but valid)
    #   assert_that(value).does_not(anything)  # Always fails
    def anything
      Minicrest::Anything.new
    end

    # Factory method for is() matcher.
    #
    # @param expected [Object] the expected reference
    # @return [Is] reference equality matcher
    def is(expected)
      Minicrest::Is.new(expected)
    end

    # Factory method for is_a() matcher.
    #
    # @param expected_type [Class, Module] the expected type
    # @return [IsA] type matcher
    def is_a(expected_type)
      Minicrest::IsA.new(expected_type)
    end

    # Factory method for responds_to() matcher.
    #
    # @param methods [Array<Symbol>] the methods to check for
    # @return [RespondsTo] method presence matcher
    def responds_to(*methods)
      Minicrest::RespondsTo.new(*methods)
    end

    # Factory method for starts_with() matcher.
    #
    # @param prefix [String] the expected prefix
    # @return [StartsWith] string prefix matcher
    def starts_with(prefix)
      Minicrest::StartsWith.new(prefix)
    end

    # Factory method for ends_with() matcher.
    #
    # @param suffix [String] the expected suffix
    # @return [EndsWith] string suffix matcher
    def ends_with(suffix)
      Minicrest::EndsWith.new(suffix)
    end

    # Factory method for matches_pattern() matcher.
    #
    # @param pattern [Regexp] the expected pattern
    # @return [MatchesPattern] regex pattern matcher
    def matches_pattern(pattern)
      Minicrest::MatchesPattern.new(pattern)
    end

    # Factory method for blank() matcher.
    #
    # @return [Blank] blank string matcher
    def blank
      Minicrest::Blank.new
    end

    # Factory method for never() combinator.
    #
    # Use this to negate any matcher.
    #
    # @param matcher [Matcher] the matcher to negate
    # @return [Not] negated matcher
    def never(matcher)
      Minicrest::Not.new(matcher)
    end

    # Factory method for all_of() combinator.
    #
    # All matchers must match.
    #
    # @param matchers [Array<Matcher>] matchers that must all match
    # @return [All] ALL combinator
    def all_of(*matchers)
      Minicrest::All.new(*matchers)
    end

    # Factory method for none_of() combinator.
    #
    # None of the matchers should match.
    #
    # @param matchers [Array<Matcher>] matchers that must all fail
    # @return [None] NONE combinator
    def none_of(*matchers)
      Minicrest::None.new(*matchers)
    end

    # Factory method for some_of() combinator.
    #
    # At least one matcher must match.
    #
    # @param matchers [Array<Matcher>] matchers where at least one must match
    # @return [Some] SOME combinator
    def some_of(*matchers)
      Minicrest::Some.new(*matchers)
    end
  end
end
