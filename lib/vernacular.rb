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
  PARSER_PATH = File.expand_path('vernacular/parser.rb', __dir__).freeze

  # Module that gets included into `RubyVM::InstructionSequence` in order to
  # hook into the require process.
  module InstructionSequenceMixin
    def load_iseq(filepath)
      ::Vernacular::SourceFile.load_iseq(filepath) if filepath != PARSER_PATH
    end
  end

  # Module that gets included into `Bootsnap::CompileCache::ISeq` in order to
  # hook into the bootsnap compilation process.
  module BootsnapMixin
    def input_to_storage(contents, filepath)
      if filepath == PARSER_PATH
        raise ::Bootsnap::CompileCache::Uncompilable, "can't compile parser"
      end

      contents = ::Vernacular.modify(contents)
      RubyVM::InstructionSequence.compile(contents, filepath, filepath).to_binary
    rescue SyntaxError
      raise ::Bootsnap::CompileCache::Uncompilable, 'syntax error'
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

      install
    end

    # Use every available pre-configured modifier
    def give_me_all_the_things!
      @modifiers =
        Modifiers.constants.map { |constant| Modifiers.const_get(constant).new }
    end

    def modify(source)
      modifiers.each do |modifier|
        source = modifier.modify(source)
      end
      source
    end

    def iseq_path_for(source_path)
      source_path.gsub(/[^A-Za-z0-9\._-]/) { |c| '%02x' % c.ord }
                 .gsub('.rb', '.yarb')
    end

    private

    def install
      @installed ||=
        if defined?(Bootsnap)
          class << Bootsnap::CompileCache::ISeq
            prepend ::Vernacular::BootsnapMixin
          end
        else
          class << RubyVM::InstructionSequence
            prepend ::Vernacular::InstructionSequenceMixin
          end
        end
    end
  end
end
