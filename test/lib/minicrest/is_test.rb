# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Is do
  include Minicrest::Assertions

  describe 'initialization' do
    it 'raises ArgumentError when passed a matcher' do
      error = assert_raises(ArgumentError) do
        is(equals(42))
      end

      assert_equal error.message, <<~MSG.chomp
        is() expects a value, not a matcher. Use is() for reference equality checks, or use matches() with the matcher directly.
      MSG
    end

    it 'raises ArgumentError when passed any matcher type' do
      assert_raises(ArgumentError) { is(never(equals(42))) }
      assert_raises(ArgumentError) { is(anything) }
      assert_raises(ArgumentError) { is(equals(1) | equals(2)) }
    end
  end

  describe '#matches?' do
    it 'returns true for the same object reference' do
      obj = Object.new

      assert is(obj).matches?(obj)
    end

    it 'returns false for different objects with the same value' do
      refute is(+'hello').matches?(+'hello')
    end

    it 'returns false for different objects' do
      refute is(Object.new).matches?(Object.new)
    end

    it 'returns true when the same reference is assigned to different variables' do
      obj = Object.new
      same_ref = obj

      assert is(obj).matches?(same_ref)
    end

    it 'works with nil' do
      assert is(nil).matches?(nil)
    end

    it 'works with symbols (interned)' do
      assert is(:foo).matches?(:foo)
    end

    it 'works with small integers (cached)' do
      assert is(42).matches?(42)
    end
  end

  describe '#description' do
    it 'describes the expected reference with object_id' do
      obj = Object.new

      assert_equal "the same object as #{obj.inspect} (object_id: #{obj.object_id})", is(obj).description
    end
  end

  describe '#failure_message' do
    it 'explains that actual is not the same object as expected with both object_ids' do
      obj1 = Object.new
      obj2 = Object.new

      assert_equal is(obj1).failure_message(obj2), <<~MSG.chomp
        expected #{obj2.inspect} (object_id: #{obj2.object_id}) to be the same object as #{obj1.inspect} (object_id: #{obj1.object_id})
      MSG
    end

    it 'shows string values clearly' do
      str1 = +'expected'
      str2 = +'actual'

      assert_equal is(str1).failure_message(str2), <<~MSG.chomp
        expected "actual" (object_id: #{str2.object_id}) to be the same object as "expected" (object_id: #{str1.object_id})
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains that actual unexpectedly is the same object' do
      obj = Object.new

      assert_equal is(obj).negated_failure_message(obj), <<~MSG.chomp
        expected #{obj.inspect} (object_id: #{obj.object_id}) not to be the same object as #{obj.inspect}, but they are the same object
      MSG
    end
  end
end
