module XPath
  module DSL
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

    def axis(name, *element_names)
      Expression.new(:axis, current, name, element_names)
    end

    def anywhere(*expressions)
      Expression.new(:anywhere, expressions)
    end

    def attr(expression)
      Expression.new(:attribute, current, expression)
    end

    def text
      Expression.new(:text, current)
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

    def where(expression)
      Expression.new(:where, current, expression)
    end
    alias_method :[], :where

    def is(expression)
      Expression.new(:is, current, expression)
    end

    def binary_operator(name, rhs)
      Expression.new(:binary_operator, name, current, rhs)
    end

    def union(*expressions)
      Union.new(*[self, expressions].flatten)
    end
    alias_method :+, :union

    def last
      function(:last)
    end

    def position
      function(:position)
    end

    def count
      method(:count)
    end

    def contains(expression)
      method(:contains, expression)
    end

    def starts_with(expression)
      method(:"starts-with", expression)
    end

    def string
      method(:string)
    end

    def substring(*expressions)
      method(:substring, *expressions)
    end

    def string_length
      method(:"string-length")
    end

    def inverse
      method(:not)
    end
    alias_method :~, :inverse

    def normalize
      method(:"normalize-space")
    end
    alias_method :n, :normalize

    def equals(rhs)
      binary_operator(:"=", rhs)
    end
    alias_method :==, :equals

    def or(rhs)
      binary_operator(:or, rhs)
    end
    alias_method :|, :or

    def and(rhs)
      binary_operator(:and, rhs)
    end
    alias_method :&, :and

    def lte(rhs)
      binary_operator(:<=, rhs)
    end
    alias_method :<=, :lte

    def lt(rhs)
      binary_operator(:<, rhs)
    end
    alias_method :<, :lt

    def gte(rhs)
      binary_operator(:>=, rhs)
    end
    alias_method :>=, :gte

    def gt(rhs)
      binary_operator(:>, rhs)
    end
    alias_method :>, :gt

    def plus(rhs)
      binary_operator(:+, rhs)
    end

    def minus(rhs)
      binary_operator(:-, rhs)
    end

    def multiply(rhs)
      binary_operator(:*, rhs)
    end
    alias_method :*, :multiply

    def divide(rhs)
      binary_operator(:div, rhs)
    end
    alias_method :/, :divide

    def mod(rhs)
      binary_operator(:mod, rhs)
    end
    alias_method :%, :mod

    def one_of(*expressions)
      expressions.map do |e|
        current.equals(e)
      end.reduce do |a, b|
        a.or(b)
      end
    end

    def next_sibling(*expressions)
      axis(:"following-sibling")[1].axis(:self, *expressions)
    end

    def previous_sibling(*expressions)
      axis(:"preceding-sibling")[1].axis(:self, *expressions)
    end
  end
end
