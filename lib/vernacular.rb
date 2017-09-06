require 'date'
require 'digest'
require 'parser'
require 'tempfile'
require 'uri'

require 'vernacular/ast_modifier'
require 'vernacular/ast_parser'
require 'vernacular/regex_modifier'
require 'vernacular/source_file'

Dir[File.expand_path('vernacular/modifiers/*', __dir__)].each do |file|
  require file
end

module Vernacular
  module InstructionSequenceMixin
    def load_iseq(filepath)
      return nil if filepath == File.expand_path('vernacular/parser.rb', __dir__)
      ::Vernacular::SourceFile.load_iseq(filepath)
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
      return if @configured

      @modifiers = []
      yield self

      digest = Digest::MD5.new
      modifiers.each do |modifier|
        digest << modifier.components.inspect
      end

      @iseq_dir = File.expand_path(File.join('../.iseq', digest.to_s), __dir__)
      FileUtils.mkdir_p(iseq_dir) unless File.directory?(iseq_dir)

      class << RubyVM::InstructionSequence
        prepend ::Vernacular::InstructionSequenceMixin
      end

      @configured = true
    end

    def iseq_path_for(source_path)
      source_path.gsub(/[^A-Za-z0-9\._-]/) { |c| '%02x' % c.ord }.gsub('.rb', '.yarb')
    end
  end
end
