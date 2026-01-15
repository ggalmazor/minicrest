# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe 'Minicrest.register_matcher' do
  describe 'defining factory methods' do
    it 'defines a method on the Assertions module' do
      matcher_class = Class.new(Minicrest::Matcher) do
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

      Minicrest.register_matcher(:greater_than) { |expected| matcher_class.new(expected) }

      assert Minicrest::Assertions.method_defined?(:greater_than)
    end

    it 'raises an error when registering a duplicate matcher name' do
      Minicrest.register_matcher(:unique_matcher_1) { Minicrest::Anything.new }

      error = assert_raises(Minicrest::Error) do
        Minicrest.register_matcher(:unique_matcher_1) { Minicrest::Anything.new }
      end

      assert_match(/unique_matcher_1.*already registered/, error.message)
    end

    it 'raises an error when no block is provided' do
      error = assert_raises(ArgumentError) do
        Minicrest.register_matcher(:no_block_matcher)
      end

      assert_match(/block required/, error.message)
    end
  end

  describe 'using registered matchers' do
    it 'is callable from a class that includes Assertions' do
      greater_than_class = Class.new(Minicrest::Matcher) do
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

      Minicrest.register_matcher(:gt_callable) { |expected| greater_than_class.new(expected) }

      test_class = Class.new do
        include Minicrest::Assertions
      end

      instance = test_class.new
      matcher = instance.gt_callable(5)

      assert matcher.is_a?(Minicrest::Matcher)
      assert matcher.matches?(10)
      refute matcher.matches?(3)
    end

    it 'works with assert_that().matches()' do
      greater_than_class = Class.new(Minicrest::Matcher) do
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

      Minicrest.register_matcher(:gt_assert) { |expected| greater_than_class.new(expected) }

      test_class = Class.new do
        include Minicrest::Assertions
      end

      instance = test_class.new
      # Should not raise
      instance.assert_that(10).matches(instance.gt_assert(5))
    end

    it 'works with combinators (&, |)' do
      greater_than_class = Class.new(Minicrest::Matcher) do
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

      Minicrest.register_matcher(:gt_combo) { |expected| greater_than_class.new(expected) }

      test_class = Class.new do
        include Minicrest::Assertions
      end

      instance = test_class.new

      # AND combinator
      combined = instance.gt_combo(5) & instance.gt_combo(3)
      assert combined.matches?(10)
      refute combined.matches?(4)

      # OR combinator
      combined = instance.gt_combo(100) | instance.gt_combo(5)
      assert combined.matches?(10)
    end

    it 'works with never()' do
      greater_than_class = Class.new(Minicrest::Matcher) do
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

      Minicrest.register_matcher(:gt_never) { |expected| greater_than_class.new(expected) }

      test_class = Class.new do
        include Minicrest::Assertions
      end

      instance = test_class.new

      # Should not raise - 3 is NOT greater than 5
      instance.assert_that(3).never(instance.gt_never(5))
    end
  end

  describe 'registering multiple matchers' do
    it 'allows registering multiple different matchers' do
      Minicrest.register_matcher(:custom_a) { Minicrest::Anything.new }
      Minicrest.register_matcher(:custom_b) { Minicrest::Anything.new }

      assert Minicrest::Assertions.method_defined?(:custom_a)
      assert Minicrest::Assertions.method_defined?(:custom_b)
    end
  end
end
