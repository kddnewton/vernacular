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
      load PARSER_PATH
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
      exec_path = Gem.activate_bin_path('racc', 'racc', [])
      `#{exec_path} --superclass=Parser::Base -o #{PARSER_PATH} #{filepath}`
      File.write(
        PARSER_PATH,
        File.read(PARSER_PATH).gsub("Ruby#{parser_version}", 'Vernacular')
      )
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
      grammar_filepath = "../../lib/parser/ruby#{parser_version}.y"
      File.read(File.expand_path(grammar_filepath, filepath))
    end

    def parser_version
      @parser_version ||= RUBY_VERSION.gsub(/\A(\d)\.(\d).+/, '\1\2')
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
