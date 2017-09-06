module Vernacular
  module Modifiers
    class TypeSafeMethodArgs < ASTModifier
      def initialize
        super do |modifier|
          modifier.extend_parser(:f_arg, 'f_arg tCOLON cpath', <<~PARSE)
            result = @builder.type_check_arg(*val)
          PARSE

          modifier.extend_builder(:type_check_arg) do |args, colon, cpath|
            location = args[0].loc.with_operator(loc(colon))
                                  .with_expression(join_exprs(args[0], cpath))
            [n(:type_check_arg, [args, cpath], location)]
          end

          modifier.build_rewriter do
            def on_def(node)
              type_checks = ''

              node.children[1].children.each do |arg|
                next unless arg.type == :type_check_arg

                arg_name = arg.children[0][0].children[0]
                type = build_constant(arg.children[1])

                type_checks << "raise ArgumentError, \"Invalid type, expected #{type}, " <<
                  "got \#{#{arg_name}.class.name}\" unless #{arg_name}.is_a?(#{type});"

                remove(arg.loc.operator)
                remove(arg.children[1].loc.expression)
              end

              unless type_checks.empty?
                insert_before(node.children[2].loc.expression, type_checks)
              end

              super
            end

            private

            def build_constant(node, suffix = nil)
              child_node, name = node.children
              new_name = suffix ? "#{name}::#{suffix}" : name
              child_node ? build_constant(child_node, new_name) : new_name
            end
          end
        end
      end
    end
  end
end
