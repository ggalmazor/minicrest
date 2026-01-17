# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::DescendsFrom do
  include Minicrest::Assertions

  describe '#matches?' do
    describe 'with exact class match' do
      it 'matches String' do
        assert descends_from(String).matches?('hello')
      end

      it 'matches Integer' do
        assert descends_from(Integer).matches?(42)
      end

      it 'matches Array' do
        assert descends_from(Array).matches?([1, 2, 3])
      end

      it 'matches Hash' do
        assert descends_from(Hash).matches?({ a: 1 })
      end

      it 'does not match wrong type' do
        refute descends_from(String).matches?(42)
        refute descends_from(Integer).matches?('hello')
      end
    end

    describe 'with inheritance' do
      it 'matches subclass against parent class' do
        # StandardError is a subclass of Exception
        error = StandardError.new('test')

        assert descends_from(Exception).matches?(error)
      end

      it 'matches against Object' do
        assert descends_from(Object).matches?('hello')
        assert descends_from(Object).matches?(42)
        assert descends_from(Object).matches?([])
      end
    end

    describe 'with module inclusion' do
      it 'matches Enumerable' do
        assert descends_from(Enumerable).matches?([1, 2, 3])
        assert descends_from(Enumerable).matches?({ a: 1 })
      end

      it 'matches Comparable' do
        assert descends_from(Comparable).matches?(42)
        assert descends_from(Comparable).matches?('hello')
      end
    end
  end

  describe '#description' do
    it 'describes the expected type' do
      assert_equal 'an instance of String', descends_from(String).description
    end
  end

  describe '#failure_message' do
    it 'shows expected and actual types' do
      matcher = descends_from(String)

      assert_equal matcher.failure_message(42), <<~MSG.chomp
        expected 42
              to be an instance of String
        but was Integer
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello').matches(descends_from(String))
    end

    it 'works with never()' do
      assert_that(42).never(descends_from(String))
    end

    it 'works with combinators' do
      assert_that('hello').matches(descends_from(String) & descends_from(Object))
      assert_that(42).matches(descends_from(String) | descends_from(Integer))
    end
  end
end
