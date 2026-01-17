# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe 'raises_error' do
  include Minicrest::Assertions

  describe '#raises_error with any error' do
    it 'passes when block raises any error' do
      assert_that { raise 'boom' }.raises_error
    end

    it 'fails when block does not raise' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { 'no error' }.raises_error
      end
      assert_includes error.message, 'expected block to raise an error'
      assert_includes error.message, 'but no error was raised'
    end
  end

  describe '#raises_error with error class' do
    it 'passes when block raises expected error class' do
      assert_that { raise ArgumentError, 'bad arg' }.raises_error(ArgumentError)
    end

    it 'passes when block raises subclass of expected error' do
      assert_that { raise ArgumentError }.raises_error(StandardError)
    end

    it 'fails when block raises different error class' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { raise TypeError, 'wrong type' }.raises_error(ArgumentError)
      end
      assert_includes error.message, 'expected block to raise ArgumentError'
      assert_includes error.message, 'but raised TypeError'
    end

    it 'fails when block does not raise' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { 'no error' }.raises_error(ArgumentError)
      end
      assert_includes error.message, 'expected block to raise ArgumentError'
      assert_includes error.message, 'but no error was raised'
    end
  end

  describe '#raises_error with error class and message matcher' do
    it 'passes when error class and message match' do
      assert_that { raise ArgumentError, 'bad input value' }.raises_error(ArgumentError, includes('bad'))
    end

    it 'fails when error class matches but message does not' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { raise ArgumentError, 'wrong' }.raises_error(ArgumentError, includes('bad'))
      end
      assert_includes error.message, 'expected block to raise ArgumentError'
      assert_includes error.message, 'with message includes "bad"'
      assert_includes error.message, 'but message was "wrong"'
    end

    it 'works with equals matcher for exact message' do
      assert_that { raise ArgumentError, 'exact message' }.raises_error(ArgumentError, equals('exact message'))
    end

    it 'works with matches_pattern matcher' do
      assert_that { raise ArgumentError, 'Error code: 123' }.raises_error(ArgumentError, matches_pattern(/\d+/))
    end
  end
end

describe 'raises_nothing' do
  include Minicrest::Assertions

  describe '#raises_nothing' do
    it 'passes when block does not raise' do
      assert_that { 'safe operation' }.raises_nothing
    end

    it 'passes when block returns nil' do
      assert_that { nil }.raises_nothing
    end

    it 'fails when block raises error' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { raise 'boom' }.raises_nothing
      end
      assert_includes error.message, 'expected block not to raise an error'
      assert_includes error.message, 'but raised RuntimeError'
      assert_includes error.message, 'boom'
    end

    it 'includes error class and message in failure' do
      error = assert_raises(Minitest::Assertion) do
        assert_that { raise ArgumentError, 'bad value' }.raises_nothing
      end
      assert_includes error.message, 'ArgumentError'
      assert_includes error.message, 'bad value'
    end
  end
end
