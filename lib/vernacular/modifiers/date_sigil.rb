module Vernacular
  module Modifiers
    class DateSigil < RegexModifier
      FORMAT = '%FT%T%:z'

      def initialize
        super(/~d\((.+?)\)/) do |match|
          date = Date.parse(match[3..-2])
          "Date.strptime('#{date.strftime(FORMAT)}', '#{FORMAT}')"
        end
      end
    end
  end
end
