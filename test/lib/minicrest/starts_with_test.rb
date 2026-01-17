# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::StartsWith do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when string starts with prefix' do
      assert starts_with('hello').matches?('hello world')
    end

    it 'does not match when string does not start with prefix' do
      refute starts_with('world').matches?('hello world')
    end

    it 'matches empty prefix (always matches)' do
      assert starts_with('').matches?('hello')
    end

    it 'matches exact string' do
      assert starts_with('hello').matches?('hello')
    end

    it 'does not match when prefix is longer than string' do
      refute starts_with('hello world!').matches?('hello')
    end
  end

  describe '#description' do
    it 'describes the expected prefix' do
      assert_equal 'a string start with "hello"', starts_with('hello').description
    end
  end

  describe '#failure_message' do
    it 'shows expected prefix and actual string' do
      assert_equal starts_with('foo').failure_message('bar'), <<~MSG.chomp
        expected "bar"
              to start with "foo"
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'shows unexpected prefix match' do
      assert_equal starts_with('hel').negated_failure_message('hello'), <<~MSG.chomp
        expected "hello"
              not to start with "hel"
        but it does
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello world').matches(starts_with('hello'))
    end

    it 'works with never()' do
      assert_that('hello world').never(starts_with('world'))
    end

    it 'works with combinators' do
      assert_that('hello world').matches(starts_with('hello') & descends_from(String))
    end
  end
end
