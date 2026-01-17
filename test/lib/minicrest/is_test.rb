# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::Is do
  include Minicrest::Assertions

  describe 'delegation to matchers' do
    it 'delegates matches? to the provided matcher' do
      assert is(anything).matches?(42)
      assert is(equals(42)).matches?(42)
      refute is(equals(42)).matches?(43)
    end

    it 'delegates description to the provided matcher' do
      assert_equal 'anything', is(anything).description
      assert_equal 'equal to 42', is(equals(42)).description
    end

    it 'delegates failure_message to the provided matcher' do
      assert_equal equals(42).failure_message(43), is(equals(42)).failure_message(43)
    end

    it 'delegates negated_failure_message to the provided matcher' do
      assert_equal equals(42).negated_failure_message(42), is(equals(42)).negated_failure_message(42)
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
