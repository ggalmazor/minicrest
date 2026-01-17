# Minicrest

Hamcrest-style composable matchers for Minitest. Write expressive, readable assertions with detailed failure messages.

## Features

- Fluent assertion API with `assert_that`
- Composable matchers using `&` (AND) and `|` (OR) operators
- Deep equality comparison for arrays and hashes with detailed diffs
- Reference equality testing
- Logical combinators: `all_of`, `none_of`, `some_of`
- Descriptive failure messages that pinpoint exactly what went wrong
- Extensible: create and register your own custom matchers

## Installation

Add to your Gemfile:

```ruby
gem 'minicrest'
```

Then run:

```bash
bundle install
```

## Usage

Include `Minicrest::Assertions` in your test class:

```ruby
require 'minicrest'

class MyTest < Minitest::Test
  include Minicrest::Assertions

  def test_basic_equality
    assert_that(42).equals(42)
  end
end
```

## Core Matchers

### Value Equality

```ruby
# Simple values
assert_that("hello").equals("hello")

# Arrays with deep comparison
assert_that([1, [2, 3]]).equals([1, [2, 3]])

# Hashes with deep comparison
assert_that({ user: { name: "Alice" } }).equals({ user: { name: "Alice" } })
```

### Reference Equality

Test that two variables point to the same object:

```ruby
obj = Object.new
assert_that(obj).is(obj)
```

### Negation

```ruby
assert_that(42).never(equals(0))
assert_that(nil).never(equals(false))

# Aliases for more natural flow
assert_that(42).is_not(0)
assert_that("hello").does_not(start_with("bye"))
```

### Placeholder Matching

Use `anything` when you don't care about a particular value:

```ruby
assert_that(some_value).matches(anything)
```

## Type and Method Matchers

### `is_a(type)` / `descends_from(type)`

Matches if the value is an instance of the expected type (including inheritance):

```ruby
assert_that("hello").matches(is_a(String))
assert_that(42).matches(descends_from(Integer))
assert_that([]).matches(is_a(Enumerable)) # works with modules
```

### `instance_of(type)`

Matches if the value is an exact instance of the expected class (no inheritance):

```ruby
assert_that("hello").matches(instance_of(String))
assert_that(42).never(instance_of(Numeric)) # Integer is a Numeric, but not exactly InstanceOf Numeric
```

### `responds_to(*methods)`

Matches if the value responds to all specified methods:

```ruby
assert_that("hello").matches(responds_to(:upcase))
assert_that([]).matches(responds_to(:push, :pop))
```

## Value Matchers

### `nil_value`

Matches if the value is `nil`:

```ruby
assert_that(nil).matches(nil_value)
assert_that(42).never(nil_value)
```

### `truthy`

Matches if the value is considered true (anything except `nil` or `false`):

```ruby
assert_that(true).matches(truthy)
assert_that(42).matches(truthy)
assert_that("hello").matches(truthy)
```

### `falsy`

Matches if the value is considered false (`nil` or `false`):

```ruby
assert_that(false).matches(falsy)
assert_that(nil).matches(falsy)
```

## String Matchers

### `starts_with(prefix)`

```ruby
assert_that("hello world").matches(starts_with("hello"))
```

### `ends_with(suffix)`

```ruby
assert_that("hello world").matches(ends_with("world"))
```

### `matches_pattern(regex)`

```ruby
assert_that("hello123").matches(matches_pattern(/\d+/))
assert_that("test@example.com").matches(matches_pattern(/\A[\w.]+@[\w.]+\z/))
```

### `blank`

Matches empty or whitespace-only strings:

```ruby
assert_that("").matches(blank)
assert_that("   ").matches(blank)
assert_that("\t\n").matches(blank)
```

## Size and Emptiness Matchers

### `empty`

Matches empty strings, arrays, or hashes:

```ruby
assert_that("").matches(empty)
assert_that([]).matches(empty)
assert_that({}).matches(empty)
```

### `has_size(expected)`

Matches values with a specific size:

```ruby
assert_that("hello").matches(has_size(5))
assert_that([1, 2, 3]).matches(has_size(3))
assert_that({ a: 1, b: 2 }).matches(has_size(2))

# Can use matchers for flexible size checks
assert_that([1, 2, 3]).matches(has_size(is_greater_than(2)))
```

## Numeric Comparison Matchers

### `is_greater_than(expected)`

```ruby
assert_that(5).matches(is_greater_than(3))
```

### `is_greater_than_or_equal_to(expected)`

```ruby
assert_that(5).matches(is_greater_than_or_equal_to(5))
assert_that(6).matches(is_greater_than_or_equal_to(5))
```

### `is_less_than(expected)`

```ruby
assert_that(3).matches(is_less_than(5))
```

### `is_less_than_or_equal_to(expected)`

```ruby
assert_that(5).matches(is_less_than_or_equal_to(5))
assert_that(4).matches(is_less_than_or_equal_to(5))
```

### `between(min, max, exclusive: false)`

Matches if the value is within the range:

```ruby
assert_that(5).matches(between(1, 10))
assert_that(10).never(between(1, 10, exclusive: true))
```

### `is_close_to(expected, delta)`

Floating-point equality with tolerance:

```ruby
assert_that(3.14159).matches(is_close_to(3.14, 0.01))
assert_that(10.0).matches(is_close_to(10.5, 0.5))
```

## Collection Content Matchers

### `includes(*items)`

Matches if the value contains all specified items:

```ruby
# Strings: contains substrings
assert_that("hello world").matches(includes("hello", "world"))

# Arrays: contains elements
assert_that([1, 2, 3, 4]).matches(includes(2, 4))

# Hashes: contains key-value pairs
assert_that({ a: 1, b: 2, c: 3 }).matches(includes(a: 1, c: 3))
```

### `has_key(*keys)`

Matches if the hash contains all specified keys:

```ruby
assert_that({ a: 1, b: 2 }).matches(has_key(:a))
assert_that({ a: 1, b: 2 }).matches(has_key(:a, :b))
```

### `has_value(*values)`

Matches if the hash contains all specified values:

```ruby
assert_that({ a: 1, b: 2 }).matches(has_value(1))
assert_that({ a: 1, b: 2 }).matches(has_value(1, 2))
```

### `contains(*items)`

Matches if the collection contains exactly the specified items in any order:

```ruby
assert_that([3, 1, 2]).matches(contains(1, 2, 3))
assert_that({ b: 2, a: 1 }).matches(contains(a: 1, b: 2))
```

### `contains_exactly(*items)`

Matches if the array contains exactly the specified items in order:

```ruby
assert_that([1, 2, 3]).matches(contains_exactly(1, 2, 3))
```

## Collection Item Matchers

### `all_items(matcher)`

Matches if all items in the collection match:

```ruby
assert_that([2, 4, 6]).matches(all_items(descends_from(Integer)))
assert_that([2, 4, 6]).matches(all_items(is_greater_than(0)))
```

### `some_items(matcher)`

Matches if at least one item matches:

```ruby
assert_that([1, "two", 3]).matches(some_items(descends_from(String)))
```

### `no_items(matcher)`

Matches if no items match:

```ruby
assert_that([1, 2, 3]).matches(no_items(descends_from(String)))
```

### `all_entries(matcher)` / `some_entry(matcher)` / `no_entry(matcher)`

Similar to item matchers, but specifically for hash entries (key-value pairs):

```ruby
# all_entries expects a matcher that works with [key, value] arrays
assert_that({ a: 1, b: 2 }).matches(all_entries(includes(:a, :b) | includes(1, 2)))

# You can also use a Proc for more complex entry matching
assert_that({ a: 1, b: 2 }).matches(some_entry(->(entry) { entry[1] > 1 }))
```

## Membership Matcher

### `is_in(collection)`

Matches if the value is present in the collection:

```ruby
assert_that(2).matches(is_in([1, 2, 3]))
assert_that(:a).matches(is_in({ a: 1, b: 2 }))  # checks keys
assert_that("el").matches(is_in("hello"))       # substring
assert_that(5).matches(is_in(1..10))            # ranges
```

## Object Attribute Matcher

### `has_attribute(name, matcher = nil)`

Matches if the object has the attribute, optionally checking its value:

```ruby
user = OpenStruct.new(name: "Alice", age: 30)

assert_that(user).matches(has_attribute(:name))
assert_that(user).matches(has_attribute(:name, equals("Alice")))
assert_that(user).matches(has_attribute(:age, is_greater_than(18)))

# Also works with hashes
assert_that({ name: "Bob" }).matches(has_attribute(:name, equals("Bob")))
```

## Error Assertions

### `raises_error`

Assert that a block raises an error:

```ruby
# Any error
assert_that { raise "boom" }.raises_error

# Specific error class
assert_that { raise ArgumentError, "bad" }.raises_error(ArgumentError)

# Error class with message matcher
assert_that { raise ArgumentError, "bad input" }.raises_error(ArgumentError, includes("bad"))
assert_that { raise ArgumentError, "code: 123" }.raises_error(ArgumentError, matches_pattern(/\d+/))
```

### `raises_nothing`

Assert that a block does not raise:

```ruby
assert_that { safe_operation }.raises_nothing
```

## Combining Matchers

Use `|` for OR and `&` for AND:

```ruby
# Either/or
assert_that(status).matches(equals(:success) | equals(:pending))

# Both conditions
assert_that(value).matches(is_greater_than(0) & is_less_than(100))

# Complex combinations
assert_that(result).matches(
  (equals(1) | equals(2)) & never(equals(nil))
)
```

### Collection Combinators

```ruby
# All matchers must pass
assert_that(5).matches(all_of(is_greater_than(0), is_less_than(10)))

# No matchers should pass
assert_that(10).matches(none_of(equals(5), equals(6)))

# At least one matcher must pass
assert_that(5).matches(some_of(equals(5), equals(999)))
```

## Custom Matchers

Create your own matchers by subclassing `Minicrest::Matcher`:

```ruby
class BePositive < Minicrest::Matcher
  def matches?(actual)
    actual.is_a?(Numeric) && actual > 0
  end

  def description
    "be positive"
  end

  def failure_message(actual)
    "expected #{actual.inspect} to be a positive number"
  end
end

# Register the matcher
Minicrest.register_matcher(:be_positive) { BePositive.new }

# Use in tests
assert_that(5).matches(be_positive)
```

### Parameterized Matchers

Matchers can accept arguments:

```ruby
class BeDivisibleBy < Minicrest::Matcher
  def initialize(divisor)
    super()
    @divisor = divisor
  end

  def matches?(actual)
    actual % @divisor == 0
  end

  def description
    "be divisible by #{@divisor}"
  end
end

Minicrest.register_matcher(:be_divisible_by) { |n| BeDivisibleBy.new(n) }

# Use in tests
assert_that(10).matches(be_divisible_by(5))
```

### Custom Matchers with Combinators

Registered matchers automatically work with all combinators:

```ruby
# With AND/OR operators
assert_that(10).matches(be_divisible_by(5) & be_divisible_by(2))
assert_that(10).matches(be_divisible_by(3) | be_divisible_by(5))

# With never()
assert_that(7).never(be_divisible_by(2))

# With all_of, some_of, none_of
assert_that(10).matches(all_of(be_positive, be_divisible_by(5)))
```

## Failure Messages

Minicrest provides detailed failure messages with diffs:

```ruby
assert_that({ name: "Bob" }).equals({ name: "Alice" })
```

Output:

```
expected {:name=>"Bob"}
      to equal {:name=>"Alice"}

Diff:
  key :name:
    expected: "Alice"
    actual:   "Bob"
```

Array diffs show the index:

```ruby
assert_that([1, 2, 4]).equals([1, 2, 3])
```

Output:

```
expected [1, 2, 4]
      to equal [1, 2, 3]

Diff:
  [2]:
    expected: 3
    actual:   4
```

String diffs show the first difference:

```ruby
assert_that("hello").equals("hallo")
```

Output:

```
expected "hello"
      to equal "hallo"

Diff:
  at index 1:
    expected: "a"
    actual:   "e"
```

## API Reference

### Assertions Module - Core

| Method | Description |
|--------|-------------|
| `assert_that(actual, message = nil)` | Entry point for value assertions |
| `assert_that { block }` | Entry point for block assertions |
| `equals(expected)` | Value equality matcher |
| `is(expected)` | Reference equality matcher |
| `anything` | Matches any value |
| `never(matcher)` | Negates a matcher (aliases: `is_not`, `does_not`) |

### Assertions Module - Type & Method

| Method | Description |
|--------|-------------|
| `is_a(type)` | Type/class matcher (alias of `descends_from`) |
| `descends_from(type)` | Type/class matcher |
| `instance_of(type)` | Exact class matcher |
| `responds_to(*methods)` | Method presence matcher |

### Assertions Module - Values

| Method | Description |
|--------|-------------|
| `nil_value` | Matches `nil` |
| `truthy` | Matches non-nil, non-false values |
| `falsy` | Matches `nil` or `false` |

### Assertions Module - Strings

| Method | Description |
|--------|-------------|
| `starts_with(prefix)` | String prefix matcher |
| `ends_with(suffix)` | String suffix matcher |
| `matches_pattern(regex)` | Regex pattern matcher |
| `blank` | Blank string matcher |

### Assertions Module - Size & Emptiness

| Method | Description |
|--------|-------------|
| `empty` | Empty collection matcher |
| `has_size(expected)` | Size/length matcher |

### Assertions Module - Numeric

| Method | Description |
|--------|-------------|
| `is_greater_than(n)` | Greater than comparison |
| `is_greater_than_or_equal_to(n)` | Greater than or equal comparison |
| `is_less_than(n)` | Less than comparison |
| `is_less_than_or_equal_to(n)` | Less than or equal comparison |
| `between(min, max, exclusive: false)` | Range comparison |
| `is_close_to(n, delta)` | Floating-point tolerance |

### Assertions Module - Collections

| Method | Description |
|--------|-------------|
| `includes(*items)` | Partial containment |
| `has_key(*keys)` | Hash key presence |
| `has_value(*values)` | Hash value presence |
| `contains(*items)` | Exact items, any order |
| `contains_exactly(*items)` | Exact items, exact order |
| `all_items(matcher)` | All items match |
| `some_items(matcher)` | At least one matches |
| `no_items(matcher)` | No items match |
| `all_entries(matcher)` | All hash entries match |
| `some_entry(matcher)` | At least one entry matches |
| `no_entry(matcher)` | No entries match |
| `is_in(collection)` | Membership check |

### Assertions Module - Objects

| Method | Description |
|--------|-------------|
| `has_attribute(name, matcher = nil)` | Object attribute matcher |

### Assertions Module - Combinators

| Method | Description |
|--------|-------------|
| `all_of(*matchers)` | All matchers must match |
| `none_of(*matchers)` | No matcher should match |
| `some_of(*matchers)` | At least one must match |

### Asserter Methods

| Method | Description |
|--------|-------------|
| `.equals(expected)` | Assert value equality |
| `.is(expected)` | Assert reference equality |
| `.never(matcher)` | Assert negation (aliases: `is_not`, `does_not`) |
| `.matches(matcher)` | Use any matcher |
| `.raises_error(class = nil, message_matcher = nil)` | Assert block raises |
| `.raises_nothing` | Assert block doesn't raise |

### Matcher Operators

| Operator | Description |
|----------|-------------|
| `&` | AND - both matchers must succeed |
| `\|` | OR - at least one matcher must succeed |

### Module Methods

| Method | Description |
|--------|-------------|
| `Minicrest.register_matcher(name, &block)` | Register custom matcher |

## License

AGPL-3.0-only

See [LICENSE](LICENSE) for details.
