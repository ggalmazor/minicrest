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
    # Creates a fluent asserter for the given value or block.
    #
    # This is the main entry point for Hamcrest-style assertions.
    # Returns an Asserter that provides chainable matcher methods.
    #
    # @param actual [Object, nil] the value to check (nil if using block)
    # @param message [String, nil] optional custom message prefix
    # @yield block to execute for error assertions
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
    #
    # @example With block for error assertions
    #   assert_that { raise "boom" }.raises_error
    #   assert_that { safe_operation }.raises_nothing
    def assert_that(actual = nil, message = nil, &)
      Asserter.new(actual, message, &)
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

    # Factory method for descends_from() matcher.
    #
    # @param expected_type [Class, Module] the expected type
    # @return [DescendsFrom] type matcher
    def descends_from(expected_type)
      Minicrest::DescendsFrom.new(expected_type)
    end

    # Factory method for instance_of() matcher.
    #
    # @param expected_type [Class] the expected type
    # @return [InstanceOf] instance_of matcher
    def instance_of(expected_type)
      Minicrest::InstanceOf.new(expected_type)
    end

    # Factory method for nil_value() matcher.
    #
    # @return [NilValue] nil matcher
    def nil_value
      Minicrest::NilValue.new
    end

    # Factory method for truthy() matcher.
    #
    # @return [Truthy] truthy matcher
    def truthy
      Minicrest::Truthy.new
    end

    # Factory method for falsy() matcher.
    #
    # @return [Falsy] falsy matcher
    def falsy
      Minicrest::Falsy.new
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

    # Factory method for empty() matcher.
    #
    # Matches empty strings, arrays, hashes, or any object that responds
    # to empty? and returns true.
    #
    # @return [Empty] empty matcher
    def empty
      Minicrest::Empty.new
    end

    # Factory method for has_size() matcher.
    #
    # Matches values with a specific size. Works with strings, arrays,
    # hashes, and any object that responds to size.
    #
    # @param expected [Integer, Matcher] the expected size or a matcher for the size
    # @return [HasSize] size matcher
    #
    # @example With integer
    #   has_size(5).matches?('hello')  # => true
    #
    # @example With matcher
    #   has_size(equals(5)).matches?('hello')  # => true
    def has_size(expected)
      Minicrest::HasSize.new(expected)
    end

    # Factory method for is_greater_than() matcher.
    #
    # @param expected [Comparable] the value to compare against
    # @return [IsGreaterThan] greater-than matcher
    def is_greater_than(expected)
      Minicrest::IsGreaterThan.new(expected)
    end

    # Factory method for is_less_than() matcher.
    #
    # @param expected [Comparable] the value to compare against
    # @return [IsLessThan] less-than matcher
    def is_less_than(expected)
      Minicrest::IsLessThan.new(expected)
    end

    # Factory method for is_greater_than_or_equal_to() matcher.
    #
    # @param expected [Comparable] the value to compare against
    # @return [IsGreaterThanOrEqualTo] greater-than-or-equal-to matcher
    def is_greater_than_or_equal_to(expected)
      Minicrest::IsGreaterThanOrEqualTo.new(expected)
    end

    # Factory method for is_less_than_or_equal_to() matcher.
    #
    # @param expected [Comparable] the value to compare against
    # @return [IsLessThanOrEqualTo] less-than-or-equal-to matcher
    def is_less_than_or_equal_to(expected)
      Minicrest::IsLessThanOrEqualTo.new(expected)
    end

    # Factory method for between() matcher.
    #
    # @param min [Comparable] the minimum value
    # @param max [Comparable] the maximum value
    # @param exclusive [Boolean] whether the range is exclusive
    # @return [Between] between matcher
    def between(min, max, exclusive: false)
      Minicrest::Between.new(min, max, exclusive:)
    end

    # Factory method for is_close_to() matcher.
    #
    # Matches if the actual value is within delta of the expected value.
    # Useful for floating-point comparisons.
    #
    # @param expected [Numeric] the expected value
    # @param delta [Numeric] the acceptable difference
    # @return [IsCloseTo] close-to matcher
    def is_close_to(expected, delta)
      Minicrest::IsCloseTo.new(expected, delta)
    end

    # Factory method for includes() matcher.
    #
    # For strings: checks for substrings
    # For arrays: checks for elements
    # For hashes: checks for key-value pairs
    #
    # @param items [Array] items that must be included
    # @return [Includes] includes matcher
    def includes(*items)
      Minicrest::Includes.new(*items)
    end

    # Factory method for has_key() matcher.
    #
    # Checks if a hash contains all specified keys.
    #
    # @param keys [Array<Symbol, String>] keys that must be present
    # @return [HasKey] has_key matcher
    def has_key(*keys)
      Minicrest::HasKey.new(*keys)
    end

    # Factory method for has_value() matcher.
    #
    # Checks if a hash contains all specified values.
    #
    # @param values [Array] values that must be present
    # @return [HasValue] has_value matcher
    def has_value(*values)
      Minicrest::HasValue.new(*values)
    end

    # Factory method for contains() matcher.
    #
    # Checks if a collection contains exactly the specified items (in any order).
    #
    # @param items [Array] items that must be contained
    # @return [Contains] contains matcher
    def contains(*items)
      Minicrest::Contains.new(*items)
    end

    # Factory method for contains_exactly() matcher.
    #
    # Checks if an array contains exactly the specified items in the specified order.
    #
    # @param items [Array] items that must be contained in order
    # @return [ContainsExactly] contains_exactly matcher
    def contains_exactly(*items)
      Minicrest::ContainsExactly.new(*items)
    end

    # Factory method for all_items() matcher.
    #
    # Checks if all items in a collection match the given matcher.
    #
    # @param item_matcher [Matcher] the matcher to apply to each item
    # @return [AllItems] all_items matcher
    def all_items(item_matcher)
      Minicrest::AllItems.new(item_matcher)
    end

    # Factory method for some_items() matcher.
    #
    # Checks if at least one item in a collection matches the given matcher.
    #
    # @param item_matcher [Matcher] the matcher to apply to each item
    # @return [SomeItems] some_items matcher
    def some_items(item_matcher)
      Minicrest::SomeItems.new(item_matcher)
    end

    # Factory method for no_items() matcher.
    #
    # Checks if no items in a collection match the given matcher.
    #
    # @param item_matcher [Matcher] the matcher to apply to each item
    # @return [NoItems] no_items matcher
    def no_items(item_matcher)
      Minicrest::NoItems.new(item_matcher)
    end

    # Factory method for all_entries() matcher.
    #
    # @param entry_matcher [Proc, Matcher] matcher for entries
    # @return [AllEntries] all_entries matcher
    def all_entries(entry_matcher)
      Minicrest::AllEntries.new(entry_matcher)
    end

    # Factory method for some_entry() matcher.
    #
    # @param entry_matcher [Proc, Matcher] matcher for entries
    # @return [SomeEntry] some_entry matcher
    def some_entry(entry_matcher)
      Minicrest::SomeEntry.new(entry_matcher)
    end

    # Factory method for no_entry() matcher.
    #
    # @param entry_matcher [Proc, Matcher] matcher for entries
    # @return [NoEntry] no_entry matcher
    def no_entry(entry_matcher)
      Minicrest::NoEntry.new(entry_matcher)
    end

    # Factory method for is_in() matcher.
    #
    # Checks if a value is present in a collection.
    # For arrays: checks element membership
    # For hashes: checks key membership
    # For strings: checks substring membership
    # For ranges: checks value inclusion
    #
    # @param collection [Array, Hash, String, Range] the collection to check
    # @return [IsIn] is_in matcher
    def is_in(collection)
      Minicrest::IsIn.new(collection)
    end

    # Factory method for has_attribute() matcher.
    #
    # Checks if an object has a specific attribute.
    # Works with objects with attr_reader and hashes.
    #
    # @param name [Symbol] the attribute name
    # @param value_matcher [Matcher, nil] optional matcher for the value
    # @return [HasAttribute] has_attribute matcher
    def has_attribute(name, value_matcher = nil)
      Minicrest::HasAttribute.new(name, value_matcher)
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
    alias is_not never
    alias does_not never

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
