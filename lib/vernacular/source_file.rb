module Vernacular
  class SourceFile
    attr_reader :source_path, :iseq_path

    def initialize(source_path, iseq_path)
      @source_path = source_path
      @iseq_path   = iseq_path
    end

    def dump
      source = File.read(source_path)
      Vernacular.modifiers.each do |modifier|
        source = modifier.modify(source)
      end

      iseq = RubyVM::InstructionSequence.compile(source)
      digest = ::Digest::SHA1.file(source_path).digest
      File.binwrite(iseq_path, iseq.to_binary("SHA-1:#{digest}"))
      iseq
    rescue SyntaxError, RuntimeError
      nil
    end

    def load
      if File.exist?(iseq_path) && (File.mtime(source_path) <= File.mtime(iseq_path))
        RubyVM::InstructionSequence.load_from_binary(File.binread(iseq_path))
      else
        dump
      end
    end

    def self.load_iseq(source_path)
      new(
        source_path,
        File.join(Vernacular.iseq_dir, Vernacular.iseq_path_for(source_path))
      ).load
    end
  end
end
