# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0 - 1.0.19] - 2026-01-18

- Housekeeping: automate CI and release workflows

## [1.0.0] - 2026-01-17

### Added

- **Core matchers**
  - `equals(expected)` - value equality with deep comparison
  - `is(expected)` - reference equality (now supports matchers as well, e.g., `is(anything)`)
  - `anything` - placeholder matcher that accepts any value
  - `never(matcher)` - negation

- **Type and method matchers**
  - `is_a(type)` (alias of `descends_from`) - type/class checking (including hierarchy)
  - `descends_from(type)` - type/class checking (including hierarchy)
  - `instance_of(type)` - exact class checking
  - `responds_to(*methods)` - method presence checking

- **Value matchers**
  - `nil_value` - matches `nil`
  - `truthy` - matches any value that is not `nil` or `false`
  - `falsy` - matches `nil` or `false`

- **String matchers**
  - `starts_with(prefix)` - string prefix matching
  - `ends_with(suffix)` - string suffix matching
  - `matches_pattern(regex)` - regex pattern matching
  - `blank` - blank string matching (empty or whitespace-only)

- **Size and emptiness matchers**
  - `empty` - empty collection matching
  - `has_size(expected)` - size/length matching (accepts matchers)

- **Numeric comparison matchers**
  - `is_greater_than(n)`
  - `is_greater_than_or_equal_to(n)`
  - `is_less_than(n)`
  - `is_less_than_or_equal_to(n)`
  - `between(min, max, exclusive: false)` - range check
  - `is_close_to(n, delta)` - floating-point tolerance

- **Collection content matchers**
  - `includes(*items)` - partial containment (strings, arrays, hashes)
  - `has_key(*keys)` - hash key presence
  - `has_value(*values)` - hash value presence
  - `contains(*items)` - exact items in any order
  - `contains_exactly(*items)` - exact items in exact order

- **Collection item matchers**
  - `all_items(matcher)` - all items must match
  - `some_items(matcher)` - at least one item must match
  - `no_items(matcher)` - no items should match
  - `all_entries(matcher)` - all hash entries must match
  - `some_entry(matcher)` - at least one hash entry must match
  - `no_entry(matcher)` - no hash entries should match

- **Membership matcher**
  - `is_in(collection)` - value membership in arrays, hashes, strings, ranges

- **Object attribute matcher**
  - `has_attribute(name, matcher = nil)` - object/hash attribute checking

- **Error assertions**
  - `raises_error(class = nil, message_matcher = nil)` - block raises error
  - `raises_nothing` - block does not raise

- **Combinators**
  - `&` operator - AND combination
  - `|` operator - OR combination
  - `all_of(*matchers)` - all matchers must match
  - `some_of(*matchers)` - at least one matcher must match
  - `none_of(*matchers)` - no matcher should match

- **Fluent API**
  - `assert_that(actual).equals(expected)`
  - `assert_that(actual).is(expected)`
  - `assert_that(actual).never(matcher)` (aliases: `is_not`, `does_not`)
  - `assert_that(actual).matches(matcher)`
  - `assert_that { block }.raises_error`
  - `assert_that { block }.raises_nothing`

- **Custom matcher API**
  - `Minicrest.register_matcher(name, &block)` - register custom matchers
  - Subclass `Minicrest::Matcher` to create custom matchers

- **Detailed failure messages**
  - Hash diffs showing missing/extra/changed keys
  - Array diffs showing index-based differences
  - String diffs showing position of first difference

[1.0.0]: https://github.com/ggalmazor/minicrest/releases/tag/v1.0.0
