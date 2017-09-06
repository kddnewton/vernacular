module Vernacular
  class ASTModifier
    BuilderExtension = Struct.new(:method, :block)
    attr_reader :builder_extensions

    ParserExtension = Struct.new(:symbol, :pattern, :code)
    attr_reader :parser_extensions

    attr_reader :rewriter_block

    def initialize
      @builder_extensions = []
      @parser_extensions = []
      yield self
    end

    def build_rewriter(&block)
      @rewriter_block = block
    end

    def extend_builder(method, &block)
      builder_extensions << BuilderExtension.new(method, block)
    end

    def extend_parser(symbol, pattern, code)
      parser_extensions << ParserExtension.new(symbol, pattern, code)
    end

    def modify(source)
      raise 'You must first configure a rewriter!' unless rewriter_block

      rewriter = Class.new(Parser::Rewriter, &rewriter_block).new
      rewriter.instance_variable_set(:@parser, ASTParser.parser)

      buffer = Parser::Source::Buffer.new('<dynamic>')
      buffer.source = source

      ast = ASTParser.parse(source)
      rewriter.rewrite(buffer, ast)
    end

    def components
      builder_extensions.flat_map { |ext| [ext.method, ext.block.source_location] } +
        parser_extensions.flat_map { |ext| [ext.symbol, ext.pattern, ext.code] } +
        rewriter_block.source_location
    end
  end
end
