# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Blank do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches empty string' do
      assert blank.matches?('')
    end

    it 'matches whitespace-only string' do
      assert blank.matches?('   ')
    end

    it 'matches tab and newline' do
      assert blank.matches?("\t\n")
    end

    it 'matches mixed whitespace' do
      assert blank.matches?("  \t  \n  ")
    end

    it 'does not match non-blank string' do
      refute blank.matches?('hello')
    end

    it 'does not match string with whitespace and content' do
      refute blank.matches?('  hello  ')
    end
  end

  describe '#description' do
    it 'describes blank expectation' do
      assert_equal blank.description, 'a blank string'
    end
  end

  describe '#failure_message' do
    it 'shows that string is not blank' do
      assert_equal blank.failure_message('hello'), <<~MSG.chomp
        expected "hello"
              to be blank
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'shows unexpected blank match' do
      assert_equal blank.negated_failure_message(''), <<~MSG.chomp
        expected ""
              not to be blank
        but it is
      MSG
    end
  end

  describe 'integration with assert_that' do
    it 'works with assert_that().matches()' do
      assert_that('').matches(blank)
      assert_that('   ').matches(blank)
    end

    it 'works with never()' do
      assert_that('hello').never(blank)
    end

    it 'works with combinators' do
      assert_that('').matches(blank & is_a(String))
    end
  end
end
