require 'date'
require 'digest'
require 'parser'
require 'tempfile'
require 'uri'

require 'vernacular/ast_modifier'
require 'vernacular/ast_parser'
require 'vernacular/configuration_hash'
require 'vernacular/regex_modifier'
require 'vernacular/source_file'

Dir[File.expand_path('vernacular/modifiers/*', __dir__)].each do |file|
  require file
end

# Allows extending ruby's syntax and compilation process
module Vernacular
  # Module that gets included into `RubyVM::InstructionSequence` in order to
  # hook into the require process.
  module InstructionSequenceMixin
    PARSER_PATH = File.expand_path('vernacular/parser.rb', __dir__).freeze

    def load_iseq(filepath)
      ::Vernacular::SourceFile.load_iseq(filepath) if filepath != PARSER_PATH
    end
  end

  class << self
    attr_reader :iseq_dir, :modifiers

    def add(modifier)
      modifiers << modifier
    end

    def clear
      Dir.glob(File.join(iseq_dir, '**/*.yarb')) { |path| File.delete(path) }
    end

    def configure
      @modifiers = []
      yield self

      hash = ConfigurationHash.new(modifiers).hash
      @iseq_dir = File.expand_path(File.join('../.iseq', hash), __dir__)
      FileUtils.mkdir_p(iseq_dir) unless File.directory?(iseq_dir)

      class << RubyVM::InstructionSequence
        prepend ::Vernacular::InstructionSequenceMixin
      end
    end

    # Use every available pre-configured modifier
    def give_me_all_the_things!
      @modifiers =
        Modifiers.constants.map { |constant| Modifiers.const_get(constant).new }
    end

    def iseq_path_for(source_path)
      source_path.gsub(/[^A-Za-z0-9\._-]/) { |c| '%02x' % c.ord }
                 .gsub('.rb', '.yarb')
    end
  end
end
