# Implementation Plan

## 1 - Expand set of available matchers

- `is_a()` to match expected type
- `responds_to()` to match expected method
- `includes()` to match the presence of elements
  - for strings, it matches if the string contains all the specified substrings. More than one substring can be specified.
  - for arrays, it matches if the array contains all the specified elements. More than one element can be specified.
  - for hashes, it matches if the hash contains all the specified key-value pairs. More than one pair can be specified.
- `contains()` to match the presence of elements in arrays and hashes
  - It matches if the array or hash contains the same provided elements, in any order
  - Can only be used with arrays and hashes
- `contains_exactly()` to match the presence of elements in arrays
  - It matches if the array contains the same provided elements, exactly in the provided order
  - Can only be used with arrays
- `starts_with()` and `ends_with()` to match the beginning and end of strings
- `has_key()` and `has_value()` to match keys and values in hashes
- `blank` to match blank strings (whitespace-only)
- `empty` to match empty strings, arrays or hashes
- `has_size()` to match the size of strings, arrays and hashes
- `matches_pattern()` to match strings using regular expressions
- `all_items()`, `some_items()`, `no_items()` to match items in an array
- `all_entries()`, `some_entry()`, `no_entry()` to match entries in a hash
- `is_greater_than()`, `is_greater_than_or_equal_to()`, `is_less_than()`, `is_less_than_or_equal_to()` to match numbers
- `is_close_to()` Floating-point number equality with tolerance
- `in()` to match if a string, element or pair is present in a string, array or hash
  - Should support providing a single value representing the string or collection, or multiple values to match against
- `has_attribute()` to match attributes of objects

## 2 - Support asserting errors

```ruby
assert_that { some_block }.raises_error(<error matcher(s)>)

assert_that { some_block }.never.raises_error
```
