# Implementation Plan

This plan follows strict TDD: write a failing test first, write minimal code to pass, refactor, commit after every green cycle.

---

## Phase 0: Custom Matcher API (Priority)

Enable end users to define their own custom matchers by subclassing `Minicrest::Matcher` and registering factory methods.

See [custom-matchers-plan.md](custom-matchers-plan.md) for detailed design.

### 0.1 Registration API

Allow users to register custom matcher classes with factory methods:

```ruby
# User defines a matcher class
class GreaterThan < Minicrest::Matcher
  def initialize(expected)
    super()
    @expected = expected
  end

  def matches?(actual)
    actual > @expected
  end

  def description
    "greater than #{@expected.inspect}"
  end
end

# Register it
Minicrest.register_matcher(:greater_than) { |expected| GreaterThan.new(expected) }

# Use in tests
assert_that(5).matches(greater_than(3))
```

TDD cycles:
- [x] Test `Minicrest.register_matcher` defines method on Assertions module
- [x] Test registered matcher is callable from test including Assertions
- [x] Test registered matcher works with `assert_that().matches()`
- [x] Test registered matcher works with combinators (`&`, `|`)
- [x] Test registering multiple matchers
- [x] Test error handling for invalid registration (no block, etc.)

### 0.2 Documentation

- [x] Add custom matcher examples to README
- [x] Document class-based approach with examples

---

## Phase 1: Type and Method Matchers

Simple matchers that check object types and capabilities.

### 1.1 `is_a(expected_type)`

Matches if the actual value is an instance of the expected type (using `is_a?`).

```ruby
assert_that("hello").matches(is_a(String))
assert_that(42).matches(is_a(Integer))
assert_that([]).matches(is_a(Enumerable))
```

TDD cycles:
- [ ] Test exact class match (`String`, `Integer`, `Array`, `Hash`)
- [ ] Test inheritance match (subclass matches parent)
- [ ] Test module inclusion match (`Enumerable`, `Comparable`)
- [ ] Test failure message describes expected vs actual type

### 1.2 `responds_to(*methods)`

Matches if the actual value responds to all specified methods.

```ruby
assert_that("hello").matches(responds_to(:upcase))
assert_that([]).matches(responds_to(:push, :pop))
```

TDD cycles:
- [ ] Test single method
- [ ] Test multiple methods (all must respond)
- [ ] Test failure when method missing
- [ ] Test failure message lists missing methods

## Phase 2: String Matchers

Matchers specific to string content.

### 2.1 `starts_with(prefix)`

Matches if the string starts with the given prefix.

```ruby
assert_that("hello world").matches(starts_with("hello"))
```

TDD cycles:
- [ ] Test matching prefix
- [ ] Test non-matching prefix
- [ ] Test empty prefix (always matches)
- [ ] Test failure message

### 2.2 `ends_with(suffix)`

Matches if the string ends with the given suffix.

```ruby
assert_that("hello world").matches(ends_with("world"))
```

TDD cycles:
- [ ] Test matching suffix
- [ ] Test non-matching suffix
- [ ] Test empty suffix (always matches)
- [ ] Test failure message

### 2.3 `matches_pattern(regex)`

Matches if the string matches the regular expression.

```ruby
assert_that("hello123").matches(matches_pattern(/\d+/))
assert_that("test@example.com").matches(matches_pattern(/\A[\w.]+@[\w.]+\z/))
```

TDD cycles:
- [ ] Test simple pattern match
- [ ] Test pattern with anchors
- [ ] Test non-matching pattern
- [ ] Test failure message shows pattern

### 2.4 `blank`

Matches blank strings (empty or whitespace-only).

```ruby
assert_that("").matches(blank)
assert_that("   ").matches(blank)
assert_that("\t\n").matches(blank)
```

TDD cycles:
- [ ] Test empty string
- [ ] Test whitespace-only string
- [ ] Test non-blank string fails
- [ ] Test nil handling (decide: match or raise?)

## Phase 3: Size and Emptiness Matchers

### 3.1 `empty`

Matches empty strings, arrays, or hashes.

```ruby
assert_that("").matches(empty)
assert_that([]).matches(empty)
assert_that({}).matches(empty)
```

TDD cycles:
- [ ] Test empty string
- [ ] Test empty array
- [ ] Test empty hash
- [ ] Test non-empty values fail
- [ ] Test failure message

### 3.2 `has_size(expected)`

Matches if the value has the expected size/length.

```ruby
assert_that("hello").matches(has_size(5))
assert_that([1, 2, 3]).matches(has_size(3))
assert_that({a: 1, b: 2}).matches(has_size(2))
```

TDD cycles:
- [ ] Test string length
- [ ] Test array size
- [ ] Test hash size
- [ ] Test size mismatch fails
- [ ] Test with matcher argument: `has_size(is_greater_than(2))`

## Phase 4: Numeric Comparison Matchers

### 4.1 `is_greater_than(expected)`

```ruby
assert_that(5).matches(is_greater_than(3))
```

TDD cycles:
- [ ] Test greater value passes
- [ ] Test equal value fails
- [ ] Test lesser value fails
- [ ] Test failure message

### 4.2 `is_greater_than_or_equal_to(expected)`

```ruby
assert_that(5).matches(is_greater_than_or_equal_to(5))
```

TDD cycles:
- [ ] Test greater value passes
- [ ] Test equal value passes
- [ ] Test lesser value fails

### 4.3 `is_less_than(expected)`

```ruby
assert_that(3).matches(is_less_than(5))
```

TDD cycles:
- [ ] Test lesser value passes
- [ ] Test equal value fails
- [ ] Test greater value fails

### 4.4 `is_less_than_or_equal_to(expected)`

```ruby
assert_that(5).matches(is_less_than_or_equal_to(5))
```

TDD cycles:
- [ ] Test lesser value passes
- [ ] Test equal value passes
- [ ] Test greater value fails

### 4.5 `is_close_to(expected, delta)`

Floating-point equality with tolerance.

```ruby
assert_that(3.14159).matches(is_close_to(3.14, 0.01))
```

TDD cycles:
- [ ] Test value within delta passes
- [ ] Test value outside delta fails
- [ ] Test exact match passes
- [ ] Test failure message shows delta

## Phase 5: Collection Content Matchers

### 5.1 `includes(*items)`

Matches if the value contains all specified items.

For strings: contains all substrings
For arrays: contains all elements
For hashes: contains all key-value pairs

```ruby
assert_that("hello world").matches(includes("hello", "world"))
assert_that([1, 2, 3, 4]).matches(includes(2, 4))
assert_that({a: 1, b: 2, c: 3}).matches(includes(a: 1, c: 3))
```

TDD cycles:
- [ ] Test string with single substring
- [ ] Test string with multiple substrings
- [ ] Test string missing substring fails
- [ ] Test array with single element
- [ ] Test array with multiple elements
- [ ] Test array missing element fails
- [ ] Test hash with single pair
- [ ] Test hash with multiple pairs
- [ ] Test hash missing pair fails
- [ ] Test failure message lists missing items

### 5.2 `has_key(*keys)`

Matches if the hash contains all specified keys.

```ruby
assert_that({a: 1, b: 2}).matches(has_key(:a))
assert_that({a: 1, b: 2}).matches(has_key(:a, :b))
```

TDD cycles:
- [ ] Test single key present
- [ ] Test multiple keys present
- [ ] Test key missing fails
- [ ] Test failure message lists missing keys

### 5.3 `has_value(*values)`

Matches if the hash contains all specified values.

```ruby
assert_that({a: 1, b: 2}).matches(has_value(1))
assert_that({a: 1, b: 2}).matches(has_value(1, 2))
```

TDD cycles:
- [ ] Test single value present
- [ ] Test multiple values present
- [ ] Test value missing fails
- [ ] Test failure message lists missing values

### 5.4 `contains(*items)`

Matches if the array or hash contains exactly the specified items, in any order.

```ruby
assert_that([3, 1, 2]).matches(contains(1, 2, 3))
assert_that({b: 2, a: 1}).matches(contains(a: 1, b: 2))
```

TDD cycles:
- [ ] Test array with same elements different order
- [ ] Test array with extra elements fails
- [ ] Test array with missing elements fails
- [ ] Test hash with same pairs different order
- [ ] Test failure message shows difference

### 5.5 `contains_exactly(*items)`

Matches if the array contains exactly the specified items in the specified order.

```ruby
assert_that([1, 2, 3]).matches(contains_exactly(1, 2, 3))
```

TDD cycles:
- [ ] Test exact match passes
- [ ] Test different order fails
- [ ] Test extra elements fails
- [ ] Test missing elements fails

## Phase 6: Collection Item Matchers

Matchers that apply other matchers to collection items.

### 6.1 `all_items(matcher)`

Matches if all array items match the given matcher.

```ruby
assert_that([2, 4, 6]).matches(all_items(is_a(Integer)))
assert_that([2, 4, 6]).matches(all_items(is_greater_than(0)))
```

TDD cycles:
- [ ] Test all items match
- [ ] Test one item fails
- [ ] Test empty array passes
- [ ] Test failure message shows failing item and index

### 6.2 `some_items(matcher)`

Matches if at least one array item matches the given matcher.

```ruby
assert_that([1, "two", 3]).matches(some_items(is_a(String)))
```

TDD cycles:
- [ ] Test one item matches
- [ ] Test multiple items match
- [ ] Test no items match fails
- [ ] Test empty array fails

### 6.3 `no_items(matcher)`

Matches if no array items match the given matcher.

```ruby
assert_that([1, 2, 3]).matches(no_items(is_a(String)))
```

TDD cycles:
- [ ] Test no items match
- [ ] Test one item matches fails
- [ ] Test empty array passes

### 6.4 `all_entries(matcher)`, `some_entry(matcher)`, `no_entry(matcher)`

Same as item matchers but for hash entries (key-value pairs).

```ruby
assert_that({a: 1, b: 2}).matches(all_entries(->(k, v) { v.is_a?(Integer) }))
```

TDD cycles:
- [ ] Test all entries match
- [ ] Test some entries match
- [ ] Test no entries match
- [ ] Test failure messages

## Phase 7: Membership Matcher

### 7.1 `in(collection)`

Matches if the actual value is present in the collection.

```ruby
assert_that(2).matches(in([1, 2, 3]))
assert_that(:a).matches(in({a: 1, b: 2}))  # checks keys
assert_that("el").matches(in("hello"))
```

TDD cycles:
- [ ] Test element in array
- [ ] Test element not in array fails
- [ ] Test key in hash
- [ ] Test substring in string
- [ ] Test with multiple collections: `in([1, 2], [3, 4])` matches if in any

## Phase 8: Object Attribute Matcher

### 8.1 `has_attribute(name, matcher = anything)`

Matches if the object has the attribute and optionally matches a value.

```ruby
user = OpenStruct.new(name: "Alice", age: 30)
assert_that(user).matches(has_attribute(:name))
assert_that(user).matches(has_attribute(:name, equals("Alice")))
assert_that(user).matches(has_attribute(:age, is_greater_than(18)))
```

TDD cycles:
- [ ] Test attribute exists (no value matcher)
- [ ] Test attribute with value matcher
- [ ] Test missing attribute fails
- [ ] Test attribute value mismatch fails
- [ ] Test works with OpenStruct
- [ ] Test works with regular objects with attr_reader
- [ ] Test works with hashes (symbol keys)

## Phase 9: Error Assertions

Support asserting that blocks raise or don't raise errors.

### 9.1 Block-based `assert_that`

```ruby
assert_that { raise "boom" }.raises_error
assert_that { raise ArgumentError, "bad" }.raises_error(ArgumentError)
assert_that { raise ArgumentError, "bad input" }.raises_error(ArgumentError, includes("bad"))
assert_that { safe_operation }.raises_nothing
```

TDD cycles:
- [ ] Test `raises_error` with any error
- [ ] Test `raises_error(ErrorClass)` matches class
- [ ] Test `raises_error(ErrorClass)` fails on wrong class
- [ ] Test `raises_error(ErrorClass, message_matcher)` matches message
- [ ] Test `raises_nothing` passes when no error
- [ ] Test `raises_nothing` fails when error raised
- [ ] Test failure message includes error details

---

## Phase 10: Technical Improvements

Existing TODOs and technical debt to address.

### 10.1 Replace custom diff logic with a gem

Location: `lib/minicrest/equals.rb:95` and `lib/minicrest/equals.rb:127`

The `Equals` matcher has custom implementations for `hash_diff` and `array_diff`. Consider replacing with an established diff gem for better maintenance and edge case handling.

TDD cycles:
- [ ] Research diff gems (e.g., `hashdiff`, `diffy`)
- [ ] Add gem dependency
- [ ] Replace `hash_diff` implementation
- [ ] Replace `array_diff` implementation
- [ ] Ensure all existing tests pass
- [ ] Verify failure message format is preserved

### 10.2 Improve error message alignment

Location: `test/lib/minicrest/asserter_test.rb:101`

The nested "to equal ..." in combinator failure messages should align with the end of "expected 44" for better readability.

Current:
```
expected 44 to match at least one of:
  to equal 42
  to equal 43
```

Improved:
```
expected 44 to match at least one of:
           to equal 42
           to equal 43
```

TDD cycles:
- [ ] Update test to expect aligned output
- [ ] Modify combinator failure message formatting
- [ ] Apply consistent alignment across all combinators

---

## Implementation Order Rationale

0. **Custom Matcher API first**: Enables extensibility, may require architectural changes that affect all other matchers. Users can then implement their own matchers while we build out the standard library.
1. **Type/Method matchers**: Simple, no dependencies, useful for later tests
2. **String matchers**: Self-contained, straightforward
3. **Size/emptiness**: Foundation for collection matchers
4. **Numeric comparisons**: Useful for `has_size` with matcher
5. **Collection content**: Uses previous matchers for comparisons
6. **Collection item matchers**: Composes with all previous matchers
7. **Membership**: Alternative syntax, lower priority
8. **Object attributes**: Composes with value matchers
9. **Error assertions**: Requires block handling, most complex
10. **Technical improvements**: Address existing TODOs and technical debt