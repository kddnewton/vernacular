module Vernacular
  module Modifiers
    class URISigil < RegexModifier
      def initialize
        super(/~u\((.+?)\)/, 'URI.parse("\1")')
      end
    end
  end
end
