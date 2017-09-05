module Vernacular
  class RegexModifier
    attr_reader :pattern, :replacement, :block

    def initialize(pattern, replacement = nil, &block)
      @pattern = pattern
      @replacement = replacement
      @block = block
    end

    def modify(source)
      source.gsub(pattern, replacement, &block)
    end
  end
end
