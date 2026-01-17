# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::IsIn do
  include Minicrest::Assertions

  describe 'with arrays' do
    describe '#matches?' do
      it 'matches when element is in array' do
        assert is_in([1, 2, 3]).matches?(2)
      end

      it 'does not match when element is not in array' do
        refute is_in([1, 2, 3]).matches?(5)
      end

      it 'matches with string elements' do
        assert is_in(%w[apple banana cherry]).matches?('banana')
      end
    end
  end

  describe 'with hashes (checks keys)' do
    describe '#matches?' do
      it 'matches when key is in hash' do
        assert is_in({ a: 1, b: 2 }).matches?(:a)
      end

      it 'does not match when key is not in hash' do
        refute is_in({ a: 1, b: 2 }).matches?(:c)
      end
    end
  end

  describe 'with strings (checks substring)' do
    describe '#matches?' do
      it 'matches when substring is in string' do
        assert is_in('hello world').matches?('ell')
      end

      it 'does not match when substring is not in string' do
        refute is_in('hello world').matches?('xyz')
      end
    end
  end

  describe 'with ranges' do
    describe '#matches?' do
      it 'matches when value is in range' do
        assert is_in(1..10).matches?(5)
      end

      it 'does not match when value is outside range' do
        refute is_in(1..10).matches?(15)
      end
    end
  end

  describe '#description' do
    it 'describes array membership' do
      assert_equal 'in [1, 2, 3]', is_in([1, 2, 3]).description
    end

    it 'describes hash membership' do
      assert_equal 'in {a: 1, b: 2}', is_in({ a: 1, b: 2 }).description
    end

    it 'describes string membership' do
      assert_equal 'in "hello"', is_in('hello').description
    end

    it 'describes range membership' do
      assert_equal 'in 1..10', is_in(1..10).description
    end
  end

  describe '#failure_message' do
    it 'explains failed array membership' do
      assert_equal is_in([1, 2, 3]).failure_message(5), <<~MSG.chomp
        expected 5 to be in [1, 2, 3]
      MSG
    end

    it 'explains failed hash membership' do
      assert_equal is_in({ a: 1, b: 2 }).failure_message(:c), <<~MSG.chomp
        expected :c to be in {a: 1, b: 2}
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected membership' do
      assert_equal is_in([1, 2, 3]).negated_failure_message(2), <<~MSG.chomp
        expected 2 not to be in [1, 2, 3], but it was
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(is_in([1, 2, 3])).matches?(5)
      refute never(is_in([1, 2, 3])).matches?(2)
    end

    it 'works with | operator' do
      valid_status = is_in(%w[pending active]) | is_in(%w[completed cancelled])

      assert valid_status.matches?('active')
      assert valid_status.matches?('completed')
      refute valid_status.matches?('invalid')
    end
  end
end
