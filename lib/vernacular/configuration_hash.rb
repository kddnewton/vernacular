# frozen_string_literal: true

module Vernacular
  # Builds a hash out of the given modifiers that represents that current state
  # of configuration. This ensures that if the configuration of `Vernacular`
  # changes between runs it doesn't pick up the old compiled files.
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
