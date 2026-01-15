# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::MatchesPattern do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when string matches pattern' do
      assert matches_pattern(/\d+/).matches?('hello123')
    end

    it 'does not match when string does not match pattern' do
      refute matches_pattern(/\d+/).matches?('hello')
    end

    it 'matches pattern with anchors' do
      assert matches_pattern(/\Ahello\z/).matches?('hello')
      refute matches_pattern(/\Ahello\z/).matches?('hello world')
    end

    it 'matches email-like pattern' do
      assert matches_pattern(/\A[\w.]+@[\w.]+\z/).matches?('test@example.com')
      refute matches_pattern(/\A[\w.]+@[\w.]+\z/).matches?('invalid')
    end
  end

  describe '#description' do
    it 'describes the expected pattern' do
      assert_equal matches_pattern(/\d+/).description, 'a string matching /\\d+/'
    end
  end

  describe '#failure_message' do
    it 'shows expected pattern and actual string' do
      assert_equal matches_pattern(/foo/).failure_message('bar'), <<~MSG.chomp
        expected "bar"
              to match pattern /foo/
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'shows unexpected pattern match' do
      assert_equal matches_pattern(/\d+/).negated_failure_message('abc123'), <<~MSG.chomp
        expected "abc123"
              not to match pattern /\\d+/
        but it does
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('hello123').matches(matches_pattern(/\d+/))
    end

    it 'works with never()' do
      assert_that('hello').never(matches_pattern(/\d+/))
    end

    it 'works with combinators' do
      assert_that('hello123').matches(matches_pattern(/\d+/) & is_a(String))
    end
  end
end
