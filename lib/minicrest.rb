# frozen_string_literal: true

# Minicrest provides Hamcrest-style composable matchers for Minitest.
#
# This library enables expressive, readable assertions with detailed
# failure messages using a fluent API. Matchers can be combined using
# logical operators to create complex matching conditions.
#
# @example Basic setup
#   require "minicrest"
#
#   class MyTest < Minitest::Test
#     include Minicrest::Assertions
#
#     def test_value_equality
#       assert_that(42).equals(42)
#     end
#
#     def test_reference_equality
#       obj = Object.new
#       assert_that(obj).is(obj)
#     end
#
#     def test_reference_inequality
#       obj1 = Object.new
#       obj2 = Object.new
#       assert_that(obj1).is_not(obj2)
#     end
#
#     def test_negation
#       assert_that(42).does_not(equals(0))
#     end
#   end
#
# @example Combined matchers
#   # Either/or matching
#   assert_that(value).matches(equals(1) | equals(2))
#
#   # Both conditions must match
#   assert_that(value).matches(does_not(equals(nil)) & does_not(equals("")))
#
# @example With ActiveSupport::TestCase
#   class ApplicationTest < ActiveSupport::TestCase
#     include Minicrest::Assertions
#   end
#
module Minicrest
  class Error < StandardError; end
end

require_relative "minicrest/matcher"
require_relative "minicrest/is"
require_relative "minicrest/equals"
require_relative "minicrest/anything"
require_relative "minicrest/combinators"
require_relative "minicrest/asserter"
require_relative "minicrest/assertions"
