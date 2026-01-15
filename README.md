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
```

### Combining Matchers

Use `|` for OR and `&` for AND:

```ruby
# Either/or
assert_that(status).matches(equals(:success) | equals(:pending))

# Both conditions
assert_that(value).matches(equals(5) & never(equals(nil)))

# Complex combinations
assert_that(result).matches(
  (equals(1) | equals(2)) & never(equals(nil))
)
```

### Collection Combinators

```ruby
# All matchers must pass
assert_that(5).matches(all_of(equals(5), never(equals(nil))))

# No matchers should pass
assert_that(10).matches(none_of(equals(5), equals(6)))

# At least one matcher must pass
assert_that(5).matches(some_of(equals(5), equals(999)))
```

### Placeholder Matching

Use `anything` when you don't care about a particular value:

```ruby
assert_that(some_value).matches(anything)
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
class BeGreaterThan < Minicrest::Matcher
  def initialize(expected)
    super()
    @expected = expected
  end

  def matches?(actual)
    actual > @expected
  end

  def description
    "be greater than #{@expected.inspect}"
  end
end

Minicrest.register_matcher(:be_greater_than) { |expected| BeGreaterThan.new(expected) }

# Use in tests
assert_that(10).matches(be_greater_than(5))
```

### Custom Matchers with Combinators

Registered matchers automatically work with all combinators:

```ruby
# With AND/OR operators
assert_that(10).matches(be_greater_than(5) & be_greater_than(3))
assert_that(10).matches(be_greater_than(100) | be_greater_than(5))

# With never()
assert_that(3).never(be_greater_than(5))

# With all_of, some_of, none_of
assert_that(10).matches(all_of(be_positive, be_greater_than(5)))
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

## API Reference

### Assertions Module

| Method                               | Description                          |
|--------------------------------------|--------------------------------------|
| `assert_that(actual, message = nil)` | Entry point for fluent assertions    |
| `equals(expected)`                   | Creates a value equality matcher     |
| `is(expected)`                       | Creates a reference equality matcher |
| `anything`                           | Matcher that accepts any value       |
| `does_not(matcher)`                  | Negates a matcher                    |
| `all_of(*matchers)`                  | All matchers must match              |
| `none_of(*matchers)`                 | No matcher should match              |
| `some_of(*matchers)`                 | At least one matcher must match      |

### Module Methods

| Method                                  | Description                               |
|-----------------------------------------|-------------------------------------------|
| `Minicrest.register_matcher(name, &block)` | Register a custom matcher factory method |

### Asserter Methods

| Method              | Description                   |
|---------------------|-------------------------------|
| `.equals(expected)` | Assert value equality         |
| `.is(expected)`     | Assert reference equality     |
| `.never(matcher)`   | Assert negation               |
| `.matches(matcher)` | Use any matcher or combinator |

### Matcher Operators

| Operator | Description                            |
|----------|----------------------------------------|
| `&`      | AND - both matchers must succeed       |
| `\|`     | OR - at least one matcher must succeed |

## License

AGPL 3.0
See [LICENSE](LICENSE) for details.