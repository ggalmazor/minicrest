# Custom Matchers Plan

This document outlines the design for enabling end users to define their own custom matchers.

## Current Architecture

### Matcher Base Class

All matchers inherit from `Minicrest::Matcher` and implement:

```ruby
class Matcher
  def matches?(actual)    # Required: returns boolean
  def description         # Required: returns string
  def failure_message(actual)         # Optional: has default
  def negated_failure_message(actual) # Optional: has default
end
```

### Factory Methods

Factory methods are defined in `Minicrest::Assertions`:

```ruby
module Assertions
  def equals(expected)
    Minicrest::Equals.new(expected)
  end
  # ...
end
```

### Composition

Matchers support `&` (AND) and `|` (OR) operators inherited from base class.

## Requirements for Custom Matchers

Users should be able to:

1. **Define custom matcher classes** that work with the library
2. **Register factory methods** so they're available in tests via `include Minicrest::Assertions`
3. **Optionally use a DSL** for simple matchers without full class definitions

## Design Options

### Option A: Class-Based with Registration

Users define a matcher class and register it:

```ruby
# In user's code
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

# Register factory method
Minicrest.register_matcher(:greater_than) { |expected| GreaterThan.new(expected) }

# Usage in tests
class MyTest < Minitest::Test
  include Minicrest::Assertions

  def test_value
    assert_that(5).matches(greater_than(3))
  end
end
```

**Pros:**
- Full control over matcher implementation
- Clear, explicit registration
- Type-safe with IDE support

**Cons:**
- Verbose for simple matchers
- Requires understanding of the class hierarchy

### Option B: DSL for Simple Matchers

Provide a DSL similar to RSpec's `define`:

```ruby
Minicrest.define_matcher :be_positive do
  match { |actual| actual > 0 }
  description { "be positive" }
  failure_message { |actual| "expected #{actual.inspect} to be positive" }
end

Minicrest.define_matcher :be_greater_than do |expected|
  match { |actual| actual > expected }
  description { "be greater than #{expected.inspect}" }
end

# Usage
assert_that(5).matches(be_positive)
assert_that(5).matches(be_greater_than(3))
```

**Pros:**
- Concise for simple matchers
- Familiar to RSpec users
- Less boilerplate

**Cons:**
- Magic/metaprogramming
- Harder to debug
- Less IDE support

### Option C: Hybrid Approach (Recommended)

Support both approaches:

1. **Class-based** for complex matchers with full control
2. **DSL** for simple one-off matchers
3. **Unified registration** that works with both

```ruby
# Approach 1: Full class (complex matchers)
class JsonPathMatcher < Minicrest::Matcher
  # ... full implementation
end
Minicrest.register_matcher(:have_json_path) { |path, value_matcher| JsonPathMatcher.new(path, value_matcher) }

# Approach 2: DSL (simple matchers)
Minicrest.define_matcher :be_positive do
  match { |actual| actual > 0 }
  description { "be positive" }
end

# Approach 3: Inline lambda (very simple matchers)
Minicrest.define_matcher :be_even,
  match: ->(actual) { actual.even? },
  description: "be even"
```

## Proposed Implementation

### Phase 1: Registration API

Add a registration mechanism to make factory methods available:

```ruby
module Minicrest
  class << self
    def register_matcher(name, &block)
      Assertions.define_method(name, &block)
    end
  end
end
```

TDD cycles:
- [ ] Test registering a matcher makes it available in Assertions
- [ ] Test registered matcher works with assert_that().matches()
- [ ] Test registered matcher works with combinators (&, |)
- [ ] Test multiple matchers can be registered
- [ ] Test error when registering duplicate name (or allow override?)

### Phase 2: Documentation

- [ ] Document class-based approach in README
- [ ] Add examples of custom matchers

---

## Future: DSL Support (Deferred)

The following features are deferred for later implementation:

### DSL Builder

A simpler DSL for defining matchers without full class definitions:

```ruby
Minicrest.define_matcher :be_positive do
  match { |actual| actual.is_a?(Numeric) && actual > 0 }
  description { "be positive" }
end
```

### Inline Definition

Hash-based definition for very simple matchers:

```ruby
Minicrest.define_matcher :be_even,
  match: ->(actual) { actual.even? },
  description: "be even"
```

## Architecture Changes Required

### Changes to Assertions Module

The `Assertions` module needs to be open for dynamic method definition:

```ruby
module Minicrest
  module Assertions
    # Existing factory methods...

    # New: Allow dynamic method definition
    def self.define_matcher_method(name, &block)
      define_method(name, &block)
    end
  end
end
```

### No Breaking Changes

This design is additive:
- Existing matchers continue to work
- Existing tests don't need changes
- Users can gradually adopt custom matchers

## Open Questions

1. **Naming conflicts**: What happens if a user registers a matcher with the same name as a built-in? Options:
   - Raise error (strict)
   - Override silently (flexible)
   - Warn and override (balanced)

2. **Scoping**: Should custom matchers be:
   - Global (available to all tests)
   - Per-module (namespaced)
   - Per-test-class (isolated)

3. **Argument handling**: For DSL matchers, how to handle:
   - No arguments: `be_positive`
   - Required arguments: `be_greater_than(5)`
   - Optional arguments: `be_close_to(5, delta: 0.1)`

## Recommendation

Start with **Phase 1 (Registration API)** as it:
- Provides immediate value
- Is simple to implement
- Establishes the pattern for Phase 2
- Doesn't require complex metaprogramming

Then implement **Phase 2 (DSL)** based on user feedback.

## Example Usage After Implementation

```ruby
# In test_helper.rb or similar
require 'minicrest'

# Simple matcher via DSL
Minicrest.define_matcher :be_positive do
  match { |actual| actual.is_a?(Numeric) && actual > 0 }
  description { "be positive" }
  failure_message { |actual| "expected #{actual.inspect} to be a positive number" }
end

# Parameterized matcher via DSL
Minicrest.define_matcher :be_within do |delta|
  match { |actual, expected| (actual - expected).abs <= delta }
  description { |expected| "be within #{delta} of #{expected}" }
end

# Complex matcher via class
class HaveJsonPath < Minicrest::Matcher
  def initialize(path, value_matcher = nil)
    super()
    @path = path
    @value_matcher = value_matcher
  end

  def matches?(actual)
    value = dig_path(actual, @path)
    return false if value.nil?
    return true if @value_matcher.nil?
    @value_matcher.matches?(value)
  end

  # ... rest of implementation
end

Minicrest.register_matcher(:have_json_path) { |*args| HaveJsonPath.new(*args) }

# In tests
class MyTest < Minitest::Test
  include Minicrest::Assertions

  def test_positive_numbers
    assert_that(5).matches(be_positive)
    assert_that(-1).matches(never(be_positive))
  end

  def test_json_response
    response = { data: { user: { name: "Alice" } } }
    assert_that(response).matches(have_json_path("data.user.name", equals("Alice")))
  end
end
```
