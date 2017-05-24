module XPath
  module DSL
    module TopLevel
      def current
        Expression.new(:this_node)
      end

      def name
        Expression.new(:function, :name, current)
      end

      def descendant(*expressions)
        Expression.new(:descendant, current, expressions)
      end

      def child(*expressions)
        Expression.new(:child, current, expressions)
      end

      def axis(name, tag_name=:*)
        Expression.new(:axis, current, name, tag_name)
      end

      def next_sibling(*expressions)
        Expression.new(:next_sibling, current, expressions)
      end

      def previous_sibling(*expressions)
        Expression.new(:previous_sibling, current, expressions)
      end

      def anywhere(*expressions)
        Expression.new(:anywhere, expressions)
      end

      def attr(expression)
        Expression.new(:attribute, current, expression)
      end

      def contains(expression)
        Expression.new(:function, :contains, current, expression)
      end

      def starts_with(expression)
        Expression.new(:function, :starts_with, current, expression)
      end

      def text
        Expression.new(:text, current)
      end

      def string
        Expression.new(:function, :string, current)
      end

      def substring(*expressions)
        Expression.new(:function, :substring, current, *expressions)
      end

      def string_length
        Expression.new(:function, :string_length, current)
      end

      def css(selector)
        Expression.new(:css, current, Literal.new(selector))
      end

      def function(name, *arguments)
        Expression.new(:function, name, *arguments)
      end

      def method(name, *arguments)
        Expression.new(:function, name, current, *arguments)
      end
    end

    module ExpressionLevel
      include XPath::DSL::TopLevel

      def where(expression)
        Expression.new(:where, current, expression)
      end
      alias_method :[], :where

      def one_of(*expressions)
        expressions.map do |e|
          Expression.new(:binary_operator, Literal.new("="), current, e)
        end.reduce do |a, b|
          Expression.new(:binary_operator, Literal.new("or"), a, b)
        end
      end

      def equals(expression)
        Expression.new(:binary_operator, Literal.new("="), current, expression)
      end
      alias_method :==, :equals

      def is(expression)
        Expression.new(:is, current, expression)
      end

      def or(expression)
        Expression.new(:binary_operator, Literal.new("or"), current, expression)
      end
      alias_method :|, :or

      def and(expression)
        Expression.new(:binary_operator, Literal.new("and"), current, expression)
      end
      alias_method :&, :and

      def union(*expressions)
        Union.new(*[self, expressions].flatten)
      end
      alias_method :+, :union

      def inverse
        Expression.new(:function, :not, current)
      end
      alias_method :~, :inverse

      def string_literal
        Expression.new(:string_literal, self)
      end

      def normalize
        Expression.new(:function, :normalize_space, current)
      end
      alias_method :n, :normalize
    end
  end
end
