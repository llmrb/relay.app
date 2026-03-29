# frozen_string_literal: true

module Relay::Cache
  ##
  # A small in-process cache that supports dynamic attribute-style access.
  #
  # Missing keys are initialized as nested InMemoryCache instances, which
  # makes it convenient for lightweight grouped state such as cached model
  # lists or provider-specific values.
  class InMemoryCache
    ##
    # @return [Relay::Cache::InMemoryCache]
    def initialize
      @cache = {}
    end

    ##
    # Handles dynamic cache reads and writes.
    #
    # Setter calls like `cache.models = value` store the value under the
    # corresponding string key. Getter calls return the stored value when
    # present, or initialize a nested InMemoryCache when missing.
    #
    # @param [Symbol] m
    # @param [Array] args
    # @return [Object]
    def method_missing(m, *args, &block)
      if m.to_s.end_with?("=")
        self[m.to_s[0..-2]] = args[0]
      elsif @cache.key?(m.to_s)
        @cache[m.to_s]
      else
        @cache[m.to_s] = InMemoryCache.new
      end
    end

    ##
    # Stores a value by key.
    # @param [String,Symbol] k
    # @param [Object] v
    # @return [Object]
    def []=(k, v)
      @cache[k.to_s] = v
    end

    ##
    # Fetches a value by key.
    # @param [String,Symbol] k
    # @return [Object,nil]
    def [](k)
      @cache[k.to_s]
    end
  end
end
