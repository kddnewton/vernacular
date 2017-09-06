module Vernacular
  class ASTParser
    def parser
      source = parser_source

      ast_modifiers.each do |modifier|
        modifier.parser_extensions.each do |parser_extension|
          source = extend_parser(source, parser_extension)
        end
      end

      with_tempfile do |file|
        file.write(source)
        compile_parser(file.path)
      end

      load 'vernacular/parser.rb'
      Parser::Vernacular.new(builder)
    end

    class << self
      def parse(string)
        parser.reset
        parser.parse(Parser::Base.send(:setup_source_buffer, '(string)', 1, string, @parser.default_encoding))
      end

      def parser
        @parser ||= new.parser
      end
    end

    private

    def ast_modifiers
      Vernacular.modifiers.grep(ASTModifier)
    end

    def builder
      modifiers = ast_modifiers

      Class.new(Parser::Builders::Default) do
        modifiers.each do |modifier|
          modifier.builder_extensions.each do |builder_extension|
            define_method(builder_extension.method, &builder_extension.block)
          end
        end
      end.new
    end

    def compile_parser(filepath)
      output = File.expand_path('../parser.rb', __FILE__)
      exec_path = Gem.activate_bin_path('racc', 'racc', [])
      `#{exec_path} --superclass=Parser::Base -o #{output} #{filepath}`
      File.write(output, File.read(output).gsub('Ruby24', 'Vernacular'))
    end

    def extend_parser(source, parser_extension)
      edited = []
      needle = "#{parser_extension.symbol}:"
      pattern = /\A\s+#{needle}/

      source.split("\n").each do |line|
        if line =~ pattern
          lhs, rhs = line.split(needle)
          edited << "#{lhs}#{needle} #{parser_extension.pattern}"
          edited << "{\n#{parser_extension.code}\n}\n#{lhs}|#{rhs}"
        else
          edited << line
        end
      end

      edited.join("\n")
    end

    def parser_source
      filepath, _ = Parser.method(:check_for_encoding_support).source_location
      File.read(File.expand_path('../../lib/parser/ruby24.y', filepath))
    end

    def with_tempfile
      file = Tempfile.new(['parser-', '.y'])
      yield file
    ensure
      file.close
      file.unlink
    end
  end
end
