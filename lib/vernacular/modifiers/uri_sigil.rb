module Vernacular
  module Modifiers
    # Extends Ruby syntax to allow URI sigils, or ~u(...). The expression
    # inside contains a valid URL.
    class URISigil < RegexModifier
      def initialize
        super(/~u\((.+?)\)/, 'URI.parse("\1")')
      end
    end
  end
end
