# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::EndsWith do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when string ends with suffix' do
      assert ends_with('world').matches?('hello world')
    end

    it 'does not match when string does not end with suffix' do
      refute ends_with('hello').matches?('hello world')
    end

    it 'matches empty suffix (always matches)' do
      assert ends_with('').matches?('hello')
    end

    it 'matches exact string' do
      assert ends_with('hello').matches?('hello')
    end

    it 'does not match when suffix is longer than string' do
      refute ends_with('hello world!').matches?('world')
    end
  end

  describe '#description' do
    it 'describes the expected suffix' do
      assert_equal ends_with('world').description, 'a string ending with "world"'
    end
  end

  describe '#failure_message' do
    it 'shows expected suffix and actual string' do
      assert_equal ends_with('foo').failure_message('bar'), <<~MSG.chomp
        expected "bar"
              to end with "foo"
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'shows unexpected suffix match' do
      assert_equal ends_with('llo').negated_failure_message('hello'), <<~MSG.chomp
        expected "hello"
              not to end with "llo"
        but it does
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello world').matches(ends_with('world'))
    end

    it 'works with never()' do
      assert_that('hello world').never(ends_with('hello'))
    end

    it 'works with combinators' do
      assert_that('hello world').matches(starts_with('hello') & ends_with('world'))
    end
  end
end
