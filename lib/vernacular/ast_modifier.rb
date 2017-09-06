module Vernacular
  class ASTModifier
    BuilderExtension = Struct.new(:method, :block)
    attr_reader :builder_extensions

    ParserExtension = Struct.new(:symbol, :pattern, :code)
    attr_reader :parser_extensions

    attr_reader :rewriter_class

    def initialize
      @builder_extensions = []
      @parser_extensions = []
      yield self
    end

    def build_rewriter(&block)
      @rewriter_class = Class.new(Parser::Rewriter, &block)
    end

    def extend_builder(method, &block)
      builder_extensions << BuilderExtension.new(method, block)
    end

    def extend_parser(symbol, pattern, &block)
      filepath, lineno = block.source_location
      code = File.readlines(filepath)[lineno..-1].take_while { |line| line.strip != 'end' }.join
      parser_extensions << ParserExtension.new(symbol, pattern, code)
    end

    def modify(source)
      raise 'You must first configure a rewriter!' unless rewriter_class

      rewriter = rewriter_class.new
      rewriter.instance_variable_set(:@parser, ASTParser.parser)

      buffer = Parser::Source::Buffer.new('<dynamic>')
      buffer.source = source

      ast = ASTParser.parse(source)
      rewriter.rewrite(buffer, ast)
    end

    def components
      builder_extensions + parser_extensions
    end
  end
end
