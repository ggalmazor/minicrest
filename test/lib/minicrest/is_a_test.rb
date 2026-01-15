# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsA do
  include Minicrest::Assertions

  describe '#matches?' do
    describe 'with exact class match' do
      it 'matches String' do
        assert is_a(String).matches?('hello')
      end

      it 'matches Integer' do
        assert is_a(Integer).matches?(42)
      end

      it 'matches Array' do
        assert is_a(Array).matches?([1, 2, 3])
      end

      it 'matches Hash' do
        assert is_a(Hash).matches?({ a: 1 })
      end

      it 'does not match wrong type' do
        refute is_a(String).matches?(42)
        refute is_a(Integer).matches?('hello')
      end
    end

    describe 'with inheritance' do
      it 'matches subclass against parent class' do
        # StandardError is a subclass of Exception
        error = StandardError.new('test')
        assert is_a(Exception).matches?(error)
      end

      it 'matches against Object' do
        assert is_a(Object).matches?('hello')
        assert is_a(Object).matches?(42)
        assert is_a(Object).matches?([])
      end
    end

    describe 'with module inclusion' do
      it 'matches Enumerable' do
        assert is_a(Enumerable).matches?([1, 2, 3])
        assert is_a(Enumerable).matches?({ a: 1 })
      end

      it 'matches Comparable' do
        assert is_a(Comparable).matches?(42)
        assert is_a(Comparable).matches?('hello')
      end
    end
  end

  describe '#description' do
    it 'describes the expected type' do
      assert_equal 'an instance of String', is_a(String).description
    end
  end

  describe '#failure_message' do
    it 'shows expected and actual types' do
      matcher = is_a(String)
      message = matcher.failure_message(42)

      assert_includes message, 'String'
      assert_includes message, 'Integer'
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello').matches(is_a(String))
    end

    it 'works with never()' do
      assert_that(42).never(is_a(String))
    end

    it 'works with combinators' do
      assert_that('hello').matches(is_a(String) & is_a(Object))
      assert_that(42).matches(is_a(String) | is_a(Integer))
    end
  end
end
