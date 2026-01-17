# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../../lib/minicrest'

describe Minicrest::HasAttribute do
  include Minicrest::Assertions

  # Test class for attribute checking
  class User
    attr_reader :name, :age, :admin

    def initialize(name:, age: nil, admin: nil)
      @name = name
      @age = age
      @admin = admin
    end

    def inspect
      "#<User name=#{@name.inspect} age=#{@age.inspect} admin=#{@admin.inspect}>"
    end
  end

  describe 'with regular objects (attr_reader)' do
    let(:user) { User.new(name: 'Alice', age: 30) }

    describe '#matches?' do
      it 'matches when attribute exists (no value matcher)' do
        assert has_attribute(:name).matches?(user)
      end

      it 'does not match when attribute is missing' do
        refute has_attribute(:email).matches?(user)
      end

      it 'matches when attribute matches value matcher' do
        assert has_attribute(:name, equals('Alice')).matches?(user)
      end

      it 'does not match when attribute value does not match' do
        refute has_attribute(:name, equals('Bob')).matches?(user)
      end

      it 'works with comparison matchers' do
        assert has_attribute(:age, is_greater_than(18)).matches?(user)
        refute has_attribute(:age, is_greater_than(50)).matches?(user)
      end
    end
  end

  describe 'with hashes (symbol keys)' do
    let(:data) { { name: 'Charlie', age: 35 } }

    describe '#matches?' do
      it 'matches when key exists' do
        assert has_attribute(:name).matches?(data)
      end

      it 'matches when key value matches' do
        assert has_attribute(:name, equals('Charlie')).matches?(data)
      end

      it 'does not match when key is missing' do
        refute has_attribute(:email).matches?(data)
      end
    end
  end

  describe '#description' do
    it 'describes attribute without value matcher' do
      assert_equal 'has attribute :name', has_attribute(:name).description
    end

    it 'describes attribute with value matcher' do
      assert_equal 'has attribute :name equal to "Alice"', has_attribute(:name, equals('Alice')).description
    end
  end

  describe '#failure_message' do
    let(:user) { User.new(name: 'Alice', age: 30) }

    it 'explains missing attribute' do
      assert_equal has_attribute(:email).failure_message(user), <<~MSG.chomp
        expected #{user.inspect} to have attribute :email
        but it does not respond to :email
      MSG
    end

    it 'explains value mismatch' do
      assert_equal has_attribute(:name, equals('Bob')).failure_message(user), <<~MSG.chomp
        expected #{user.inspect} to have attribute :name equal to "Bob"
        but :name was "Alice"
      MSG
    end
  end

  describe '#negated_failure_message' do
    let(:user) { User.new(name: 'Alice') }

    it 'explains unexpected attribute' do
      assert_equal has_attribute(:name).negated_failure_message(user), <<~MSG.chomp
        expected #{user.inspect} not to have attribute :name, but it did
      MSG
    end
  end

  describe 'with combinators' do
    let(:user) { User.new(name: 'Alice', age: 30, admin: true) }

    it 'works with & operator' do
      adult_admin = has_attribute(:age, is_greater_than(18)) & has_attribute(:admin, equals(true))

      assert adult_admin.matches?(user)
    end

    it 'works with | operator' do
      has_name_or_email = has_attribute(:name) | has_attribute(:email)

      assert has_name_or_email.matches?(user)
    end
  end
end
