# Minicrest

[![CI](https://github.com/ggalmazor/minicrest/actions/workflows/ci.yml/badge.svg)](https://github.com/ggalmazor/minicrest/actions/workflows/ci.yml) [![Release](https://github.com/ggalmazor/minicrest/actions/workflows/release.yml/badge.svg)](https://github.com/ggalmazor/minicrest/actions/workflows/release.yml)

Hamcrest-style composable matchers for Minitest. Write expressive, readable assertions with detailed failure messages.

[Documentation](https://ggalmazor.com/minicrest/)

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

See [USAGE.md](USAGE.md) for more details and a full list of available matchers.

## Running Tests

To run the library's own tests:

```bash
rake test
```

## License

AGPL-3.0-only

See [LICENSE](LICENSE) for details.
