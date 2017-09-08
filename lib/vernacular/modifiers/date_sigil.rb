module Vernacular
  module Modifiers
    # Extends Ruby syntax to allow date sigils, or ~d(...). The date inside is
    # parsed and as an added benefit if it is a set value it is replaced with
    # the more efficient `strptime`.
    class DateSigil < RegexModifier
      FORMAT = '%FT%T%:z'.freeze

      def initialize
        super(/~d\((.+?)\)/) do |match|
          content = match[3..-2]
          begin
            date = Date.parse(content)
            "Date.strptime('#{date.strftime(FORMAT)}', '#{FORMAT}')"
          rescue ArgumentError
            "Date.parse(#{content})"
          end
        end
      end
    end
  end
end
