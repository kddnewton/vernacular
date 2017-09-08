module Vernacular
  module Modifiers
    # Extends Ruby syntax to allow typed method return declarations, as in:
    #     def my_method(argument_a, argument_b) = return_type; end
    class TypedMethodReturns < ASTModifier
      def initialize
        super

        extend_parser(:f_arglist, 'f_arglist tEQL cpath', <<~PARSE)
          result = @builder.type_check_arglist(*val)
        PARSE

        extend_builder(:type_check_arglist) do |arglist, equal, cpath|
          arglist << n(:type_check_arglist, [equal, cpath], nil)
        end

        build_rewriter { include TypedMethodReturnsRewriter }
      end

      # Methods to be included in the rewriter in order to handle
      # `type_check_arglist` nodes.
      module TypedMethodReturnsRewriter
        def on_def(method_node)
          type_check_node = type_check_node_from(method_node)
          return super unless type_check_node

          type_node = type_check_node.children[1]
          remove(type_check_node.children[0][1])
          remove(type_node.loc.expression)
          type_check_method(method_node, type_node)

          super
        end

        private

        def build_constant(node, suffix = nil)
          child_node, name = node.children
          new_name = suffix ? "#{name}::#{suffix}" : name
          child_node ? build_constant(child_node, new_name) : new_name
        end

        def type_check_node_from(method_node)
          type_check_node = method_node.children[1].children.last
          return if !type_check_node ||
                    type_check_node.type != :type_check_arglist
          type_check_node
        end

        def type_check_method(method_node, type_node)
          expression = method_node.children[2].loc.expression
          type = build_constant(type_node)

          @source_rewriter.transaction do
            insert_before(expression, "result = begin\n")
            insert_after(expression, "\nend\nraise \"Invalid return value, " \
              "expected #{type}, got \#{result.class.name}\" unless " \
              "result.is_a?(#{type})\nresult")
          end
        end
      end
    end
  end
end
