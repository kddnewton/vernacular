module Vernacular
  # Handles monkeying around with the `parser` gem to get it to handle the
  # various modifications that users can configure `Vernacular` to perform.
  class ASTParser
    def parser
      source = parser_source

      ast_modifiers.each do |modifier|
        modifier.parser_extensions.each do |parser_extension|
          source = extend_parser(source, parser_extension)
        end
      end

      write_parser(source)
      load 'vernacular/parser.rb'
      Parser::Vernacular.new(builder)
    end

    class << self
      def parse(string)
        parser.reset
        buffer = Parser::Base.send(:setup_source_buffer, '(string)', 1, string,
                                   @parser.default_encoding)
        parser.parse(buffer)
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

    # rubocop:disable Metrics/MethodLength
    def extend_parser(source, parser_extension)
      needle = "#{parser_extension.symbol}:"
      pattern = /\A\s+#{needle}/

      source.split("\n").each_with_object([]) do |line, edited|
        if line =~ pattern
          lhs, rhs = line.split(needle)
          edited << "#{lhs}#{needle} #{parser_extension.pattern}\n" \
                    "{\n#{parser_extension.code}\n}\n#{lhs}|#{rhs}"
        else
          edited << line
        end
      end.join("\n")
    end
    # rubocop:enable Metrics/MethodLength

    def parser_source
      filepath, = Parser.method(:check_for_encoding_support).source_location
      File.read(File.expand_path('../../lib/parser/ruby24.y', filepath))
    end

    def write_parser(source)
      file = Tempfile.new(['parser-', '.y'])
      file.write(source)
      compile_parser(file.path)
    ensure
      file.close
      file.unlink
    end
  end
end
