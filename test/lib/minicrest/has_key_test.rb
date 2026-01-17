# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::HasKey do
  include Minicrest::Assertions

  describe '#matches?' do
    it 'matches when hash contains single key' do
      assert has_key(:a).matches?({ a: 1, b: 2 })
    end

    it 'matches when hash contains multiple keys' do
      assert has_key(:a, :b).matches?({ a: 1, b: 2, c: 3 })
    end

    it 'does not match when hash missing key' do
      refute has_key(:d).matches?({ a: 1, b: 2 })
    end

    it 'does not match when hash missing any key' do
      refute has_key(:a, :d).matches?({ a: 1, b: 2 })
    end

    it 'works with string keys' do
      assert has_key('name').matches?({ 'name' => 'Alice', 'age' => 30 })
    end
  end

  describe '#description' do
    it 'describes single key' do
      assert_equal 'has key :a', has_key(:a).description
    end

    it 'describes multiple keys' do
      assert_equal 'has keys :a, :b', has_key(:a, :b).description
    end
  end

  describe '#failure_message' do
    it 'lists missing keys' do
      assert_equal has_key(:c, :d).failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} to have keys :c, :d
        missing: :c, :d
      MSG
    end

    it 'shows only missing keys when some present' do
      assert_equal has_key(:a, :d).failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} to have keys :a, :d
        missing: :d
      MSG
    end
  end

  describe '#negated_failure_message' do
    it 'explains unexpected key presence' do
      assert_equal has_key(:a).negated_failure_message({ a: 1, b: 2 }), <<~MSG.chomp
        expected {a: 1, b: 2} not to have key :a, but it did
      MSG
    end
  end

  describe 'with combinators' do
    it 'works with never' do
      assert never(has_key(:c)).matches?({ a: 1, b: 2 })
      refute never(has_key(:a)).matches?({ a: 1, b: 2 })
    end

    it 'works with & operator' do
      assert (has_key(:a) & has_key(:b)).matches?({ a: 1, b: 2 })
      refute (has_key(:a) & has_key(:c)).matches?({ a: 1, b: 2 })
    end
  end
end
