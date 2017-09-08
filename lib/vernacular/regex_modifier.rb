module Vernacular
  # Represents a modification to Ruby source that should be injected into the
  # require process that modifies the source via a regex pattern.
  class RegexModifier
    attr_reader :pattern, :replacement, :block

    def initialize(pattern, replacement = nil, &block)
      @pattern = pattern
      @replacement = replacement
      @block = block
    end

    def modify(source)
      if replacement
        source.gsub(pattern, replacement)
      else
        source.gsub(pattern, &block)
      end
    end

    def components
      [pattern, replacement] + (block ? block.source_location : [])
    end
  end
end
