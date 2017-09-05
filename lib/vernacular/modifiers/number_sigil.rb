module Vernacular
  module Modifiers
    class NumberSigil < RegexModifier
      def initialize
        super(/~n\(([\d\s+-\/*\(\)]+?)\)/) { |match| eval(match[3..-2]) }
      end
    end
  end
end
