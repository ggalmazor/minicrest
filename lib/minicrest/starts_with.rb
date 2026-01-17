# frozen_string_literal: true

require_relative 'string_matcher'

module Minicrest
  # Matcher that checks if a string starts with a given prefix.
  #
  # @example Basic usage
  #   starts_with("hello").matches?("hello world")  # => true
  #   starts_with("world").matches?("hello world")  # => false
  # @see StringMatcher
  class StartsWith < StringMatcher
    # Creates a new starts_with matcher.
    #
    # @param prefix [String] the expected prefix
    def initialize(prefix)
      super(prefix, :start_with?, 'start with')
    end
  end
end
