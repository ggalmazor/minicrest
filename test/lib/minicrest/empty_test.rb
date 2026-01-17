# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Empty do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches empty string' do
      assert empty.matches?('')
    end

    it 'matches empty array' do
      assert empty.matches?([])
    end

    it 'matches empty hash' do
      assert empty.matches?({})
    end

    it 'does not match non-empty string' do
      refute empty.matches?('hello')
    end

    it 'does not match non-empty array' do
      refute empty.matches?([1, 2, 3])
    end

    it 'does not match non-empty hash' do
      refute empty.matches?({ a: 1 })
    end

    it 'does not match whitespace-only string' do
      refute empty.matches?('   ')
    end
  end

  describe '#description' do
    it "returns 'empty'" do
      assert_equal 'empty', empty.description
    end
  end

  describe '#failure_message' do
    it 'explains that string was not empty' do
      assert_equal empty.failure_message('hello'), <<~MSG.chomp
        expected "hello" to be empty, but had size 5
      MSG
    end

    it 'explains that array was not empty' do
      assert_equal empty.failure_message([1, 2, 3]), <<~MSG.chomp
        expected [1, 2, 3] to be empty, but had size 3
      MSG
    end

    it 'explains that hash was not empty' do
      assert_equal empty.failure_message({ a: 1 }), <<~MSG.chomp
        expected {a: 1} to be empty, but had size 1
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that value was unexpectedly empty' do
      assert_equal empty.negated_failure_message(''), <<~MSG.chomp
        expected "" not to be empty, but it was
      MSG
    end

    it 'explains that array was unexpectedly empty' do
      assert_equal empty.negated_failure_message([]), <<~MSG.chomp
        expected [] not to be empty, but it was
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(empty).matches?('hello')
      refute never(empty).matches?('')
    end

    it 'works with & operator' do
      assert (empty & descends_from(String)).matches?('')
      refute (empty & descends_from(String)).matches?([])
    end

    it 'works with | operator' do
      assert (empty | equals('hello')).matches?('')
      assert (empty | equals('hello')).matches?('hello')
      refute (empty | equals('hello')).matches?('world')
    end
  end
end
