module Vernacular
  class ConfigurationHash
    attr_reader :modifiers

    def initialize(modifiers = [])
      @modifiers = modifiers
    end

    def hash
      digest = Digest::MD5.new
      modifiers.each do |modifier|
        digest << modifier.components.inspect
      end
      digest.to_s
    end
  end
end
