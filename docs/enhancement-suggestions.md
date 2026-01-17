# Enhancement Suggestions

Review and edit this list before implementation. Remove or modify items as needed.

---

## 1. Refactoring - Reduce Code Duplication

### 1.1 Extract ComparisonMatcher base class

**Files affected**: `is_greater_than.rb`, `is_less_than.rb`, `is_greater_than_or_equal_to.rb`, `is_less_than_or_equal_to.rb`

**Current state**: Four nearly identical files differing only in operator (`>`, `<`, `>=`, `<=`) and description text.

**Proposed**: Create `ComparisonMatcher` base class that accepts operator and description.

- [ ] Implement

---

### 1.2 Extract CollectionItemMatcher base class

**Files affected**: `all_items.rb`, `some_items.rb`, `no_items.rb`

**Current state**: Three files with identical constructor and similar structure.

**Proposed**: Create base class with shared `@item_matcher` initialization and description helpers.

- [ ] Implement

---

### 1.3 Extract StringMatcher base class

**Files affected**: `starts_with.rb`, `ends_with.rb`

**Current state**: Nearly identical implementations differing in method called (`start_with?` vs `end_with?`).

**Proposed**: Create base class or use template method pattern.

- [ ] Implement

---

## 2. Missing Features

### 2.1 Hash entry matchers (Phase 6.4)

**Status**: Not implemented from original plan.

**Proposed matchers**:
- `all_entries(matcher)` - All hash entries match
- `some_entry(matcher)` - At least one entry matches
- `no_entry(matcher)` - No entries match

**Example usage**:
```ruby
assert_that({a: 1, b: 2}).matches(all_entries(->(k, v) { v.is_a?(Integer) }))
```

- [ ] Implement

---

### 2.2 Add `between(min, max)` matcher

**Current workaround**: `is_greater_than(min) & is_less_than(max)`

**Proposed**: Dedicated `between` matcher for cleaner range checking.

```ruby
assert_that(5).matches(between(1, 10))
assert_that(5).matches(between(1, 10, exclusive: true))  # optional
```

- [ ] Implement

---

### 2.3 Add `nil_value` matcher

**Current workaround**: `equals(nil)`

**Proposed**: More readable nil checking.

```ruby
assert_that(result).matches(nil_value)
assert_that(result).never(nil_value)
```

- [ ] Implement

---

### 2.4 Add `truthy` and `falsy` matchers

**Use case**: Check Ruby truthiness without exact value matching.

```ruby
assert_that(result).matches(truthy)   # anything except nil/false
assert_that(result).matches(falsy)    # nil or false
```

- [ ] Implement

---

### 2.5 Add `instance_of(type)` matcher

**Difference from `is_a`**: Exact type match, no subclasses.

```ruby
assert_that("hello").matches(instance_of(String))     # passes
assert_that(StandardError.new).matches(instance_of(Exception))  # fails (is subclass)
```

- [ ] Implement

---

## 3. Robustness Improvements

### 3.1 Add type checking to string matchers

**Files affected**: `starts_with.rb`, `ends_with.rb`, `matches_pattern.rb`, `blank.rb`

**Current behavior**: Raises confusing `NoMethodError` on non-string input.

**Proposed**: Return `false` or raise descriptive error for type mismatches.

```ruby
def matches?(actual)
  return false unless actual.respond_to?(:start_with?)
  actual.start_with?(@prefix)
end
```

- [ ] Implement

---

### 3.2 Add type checking to numeric matchers

**Files affected**: `is_greater_than.rb`, `is_less_than.rb`, etc.

**Current behavior**: Raises `ArgumentError` or `NoMethodError` on incompatible types.

**Proposed**: Better error messages for type mismatches.

- [ ] Implement

---

### 3.3 Add type checking to collection matchers

**Files affected**: `all_items.rb`, `some_items.rb`, `no_items.rb`, `has_key.rb`, `has_value.rb`

**Current behavior**: May raise confusing errors on non-collection input.

**Proposed**: Check for expected type/interface before operating.

- [ ] Implement

---

## 4. API Consistency

### 4.1 Consider renaming `is_a` to avoid shadowing

**Issue**: `is_a()` shadows Ruby's `Object#is_a?` method.

**Options**:
- Keep as-is (Hamcrest convention)
- Rename to `a` or `an` (`assert_that(x).matches(a(String))`)
- Rename to `is_type` or `of_type`

- [ ] Decide and implement (if changing)

---

### 4.2 Add Asserter shortcuts for common matchers

**Current**: Only `equals()` and `is()` have direct Asserter methods.

**Proposed**: Add shortcuts for frequently used matchers:
```ruby
assert_that(value).is_a(String)        # instead of .matches(is_a(String))
assert_that(value).includes("foo")     # instead of .matches(includes("foo"))
assert_that(value).is_greater_than(5)  # instead of .matches(is_greater_than(5))
```

- [ ] Implement

---

### 4.3 Consolidate negation naming

**Current**: `never()` factory method exists, but docs sometimes reference `does_not`.

**Proposed**: Ensure consistent naming throughout docs and API.

- [ ] Review and update

---

## 5. Documentation

### 5.1 Add module-level documentation

**Files missing docs**: `equals.rb`, `is.rb` (flagged by RuboCop, currently excluded)

- [ ] Add documentation

---

### 5.2 Add YARD @see cross-references

**Proposed**: Link related matchers in documentation (e.g., `is_a` references `instance_of`).

- [ ] Implement

---

## Priority Ranking (Suggested)

1. **High**: 2.1 (Hash entry matchers - completes Phase 6)
2. **Medium**: 1.1, 1.2, 1.3 (Refactoring - reduces maintenance burden)
3. **Medium**: 3.1, 3.2, 3.3 (Robustness - better error messages)
4. **Low**: 2.2-2.5 (New matchers - nice to have)
5. **Low**: 4.1-4.3 (API consistency - breaking changes or scope creep)
