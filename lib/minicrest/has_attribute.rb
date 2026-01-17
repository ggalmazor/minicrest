# frozen_string_literal: true

module Minicrest
  # Matcher that checks if an object has a specific attribute.
  #
  # Works with:
  # - Objects with attr_reader methods
  # - Hashes (with symbol keys)
  #
  # @example Check attribute exists
  #   has_attribute(:name).matches?(user)  # => true if user responds to :name
  #
  # @example Check attribute value
  #   has_attribute(:name, equals('Alice')).matches?(user)
  #   has_attribute(:age, is_greater_than(18)).matches?(user)
  class HasAttribute < Matcher
    # Creates a new has_attribute matcher.
    #
    # @param name [Symbol] the attribute name to check
    # @param value_matcher [Matcher, nil] optional matcher for the attribute value
    def initialize(name, value_matcher = nil)
      super()
      @name = name
      @value_matcher = value_matcher
    end

    # Checks if actual has the attribute and optionally matches the value.
    #
    # @param actual [Object] the object to check
    # @return [Boolean] true if attribute exists (and value matches if specified)
    def matches?(actual)
      return false unless has_attribute?(actual)
      return true if @value_matcher.nil?

      @value_matcher.matches?(get_attribute(actual))
    end

    # Returns a description of what this matcher expects.
    #
    # @return [String] description
    def description
      if @value_matcher
        "has attribute #{@name.inspect} #{@value_matcher.description}"
      else
        "has attribute #{@name.inspect}"
      end
    end

    # Returns the failure message when the match fails.
    #
    # @param actual [Object] the object that was checked
    # @return [String] failure message
    def failure_message(actual)
      unless has_attribute?(actual)
        return <<~MSG.chomp
          expected #{actual.inspect} to have attribute #{@name.inspect}
          but it does not respond to #{@name.inspect}
        MSG
      end

      value = get_attribute(actual)
      <<~MSG.chomp
        expected #{actual.inspect} to have attribute #{@name.inspect} #{@value_matcher.description}
        but #{@name.inspect} was #{value.inspect}
      MSG
    end

    # Returns the failure message when a negated match fails.
    #
    # @param actual [Object] the object that was checked
    # @return [String] message indicating unexpected attribute
    def negated_failure_message(actual)
      <<~MSG.chomp
        expected #{actual.inspect} not to have attribute #{@name.inspect}, but it did
      MSG
    end

    private

    def has_attribute?(actual)
      if actual.is_a?(Hash)
        actual.key?(@name)
      else
        actual.respond_to?(@name)
      end
    end

    def get_attribute(actual)
      if actual.is_a?(Hash)
        actual[@name]
      else
        actual.send(@name)
      end
    end
  end
end
