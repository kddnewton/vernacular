$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'vernacular'

Vernacular.configure do |config|
  config.add Vernacular::Modifiers::DateSigil.new
  config.add Vernacular::Modifiers::NumberSigil.new
  config.add Vernacular::Modifiers::URISigil.new
  config.add Vernacular::Modifiers::TypedMethodArgs.new
  config.add Vernacular::Modifiers::TypedMethodReturns.new
end
