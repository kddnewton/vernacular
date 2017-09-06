module Vernacular
  module Modifiers
    class TypedMethodReturns < ASTModifier
      def initialize
        super do |modifier|
          modifier.extend_parser(:f_arglist, 'f_arglist tEQL cpath', <<~PARSE)
            result = @builder.type_check_arglist(*val)
          PARSE

          modifier.extend_builder(:type_check_arglist) do |arglist, equal, cpath|
            arglist << n(:type_check_arglist, [equal, cpath], nil)
          end

          modifier.build_rewriter do
            def on_def(node)
              type_check_node = node.children[1].children.last
              return super if !type_check_node || type_check_node.type != :type_check_arglist

              remove(type_check_node.children[0][1])
              remove(type_check_node.children[1].loc.expression)
              type = build_constant(type_check_node.children[1])

              @source_rewriter.transaction do
                insert_before(node.children[2].loc.expression, "result = begin\n")
                insert_after(node.children[2].loc.expression,
                  "\nend\nraise \"Invalid return value, expected #{type}, " <<
                  "got \#{result.class.name}\" unless result.is_a?(#{type})\nresult")
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
