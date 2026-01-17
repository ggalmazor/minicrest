# frozen_string_literal: true

require_relative 'string_matcher'

module Minicrest
  # Matcher that checks if a string ends with a given suffix.
  #
  # @example Basic usage
  #   ends_with("world").matches?("hello world")  # => true
  #   ends_with("hello").matches?("hello world")  # => false
  # @see StringMatcher
  class EndsWith < StringMatcher
    # Creates a new ends_with matcher.
    #
    # @param suffix [String] the expected suffix
    def initialize(suffix)
      super(suffix, :end_with?, 'end with')
    end
  end
end
