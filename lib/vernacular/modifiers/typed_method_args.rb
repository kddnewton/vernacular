module Vernacular
  module Modifiers
    # Extends Ruby syntax to allow typed method argument declarations, as in:
    #     def my_method(argument_a : Integer, argument_b : String); end
    class TypedMethodArgs < ASTModifier
      def initialize
        super

        extend_parser(:f_arg, 'f_arg tCOLON cpath', <<~PARSE)
          result = @builder.type_check_arg(*val)
        PARSE

        extend_builder(:type_check_arg) do |args, colon, cpath|
          location = args[0].loc.with_operator(loc(colon))
                            .with_expression(join_exprs(args[0], cpath))
          [n(:type_check_arg, [args, cpath], location)]
        end

        build_rewriter { include TypedMethodArgsRewriter }
      end

      # Methods to be included in the rewriter in order to handle
      # `type_check_arg` nodes.
      module TypedMethodArgsRewriter
        # Triggered whenever a `:def` node is added to the AST. Finds any
        # `type_check_arg` nodes, replaces them with normal `:arg` nodes, and
        # adds in the represented type check to the beginning of the method.
        def on_def(node)
          type_checks = build_type_checks(node.children[1].children)
          if type_checks.any?
            insert_before(node.children[2].loc.expression, type_checks.join)
          end

          super
        end

        private

        def build_constant(node, suffix = nil)
          child_node, name = node.children
          new_name = suffix ? "#{name}::#{suffix}" : name
          child_node ? build_constant(child_node, new_name) : new_name
        end

        def build_type_checks(arg_list_node)
          arg_list_node.each_with_object([]) do |arg, type_checks|
            next unless arg.type == :type_check_arg

            type_checks << type_check(arg)
            remove(arg.loc.operator)
            remove(arg.children[1].loc.expression)
          end
        end

        def type_check(arg_node)
          arg_name = arg_node.children[0][0].children[0]
          type = build_constant(arg.children[1])
          "raise ArgumentError, \"Invalid type, expected #{type}, got " \
            "\#{#{arg_name}.class.name}\" unless #{arg_name}.is_a?(#{type});"
        end
      end
    end
  end
end
