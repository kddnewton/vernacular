module Vernacular
  module Modifiers
    # Extends Ruby syntax to allow number sigils, or ~n(...). The expression
    # inside is parsed and evaluated, and is replaced by the result.
    class NumberSigil < RegexModifier
      def initialize
        super(%r{~n\(([\d\s+-/*\(\)]+?)\)}) do |match|
          eval(match[3..-2]) # rubocop:disable Security/Eval
        end
      end
    end
  end
end
