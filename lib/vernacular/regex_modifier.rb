module Vernacular
  class RegexModifier
    attr_reader :pattern, :replacement, :block

    def initialize(pattern, replacement = nil, &block)
      @pattern = pattern
      @replacement = replacement
      @block = block
    end

    def modify(source)
      replacement ?
        source.gsub(pattern, replacement) :
        source.gsub(pattern, &block)
    end

    def components
      [pattern, replacement, block && block.source_location]
    end
  end
end
