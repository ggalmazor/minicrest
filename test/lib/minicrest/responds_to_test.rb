# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::RespondsTo do
  include Minicrest::Assertions

  describe '#matches?' do
    describe 'with single method' do
      it 'matches when object responds to method' do
        assert responds_to(:upcase).matches?('hello')
      end

      it 'does not match when object does not respond to method' do
        refute responds_to(:upcase).matches?(42)
      end
    end

    describe 'with multiple methods' do
      it 'matches when object responds to all methods' do
        assert responds_to(:push, :pop, :size).matches?([])
      end

      it 'does not match when object is missing any method' do
        refute responds_to(:upcase, :nonexistent_method).matches?('hello')
      end
    end
  end

  describe '#description' do
    it 'describes single method' do
      assert_equal 'respond to :upcase', responds_to(:upcase).description
    end

    it 'describes multiple methods' do
      assert_equal 'respond to :push, :pop', responds_to(:push, :pop).description
    end
  end

  describe '#failure_message' do
    it 'shows expected methods and lists missing ones' do
      matcher = responds_to(:upcase, :nonexistent)

      assert_equal matcher.failure_message('hello'), <<~MSG.chomp
        expected "hello"
              to respond to :upcase, :nonexistent
        missing: :nonexistent
      MSG
    end

    it 'lists all missing methods when none respond' do
      matcher = responds_to(:foo, :bar)

      assert_equal matcher.failure_message(42), <<~MSG.chomp
        expected 42
              to respond to :foo, :bar
        missing: :foo, :bar
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello').matches(responds_to(:upcase, :downcase))
    end

    it 'works with never()' do
      assert_that(42).never(responds_to(:upcase))
    end

    it 'works with combinators' do
      assert_that('hello').matches(responds_to(:upcase) & descends_from(String))
    end
  end
end
