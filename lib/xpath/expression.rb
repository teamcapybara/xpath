module XPath
  class Expression
    include XPath

    class Self < Expression
      def to_xpath
        '.'
      end
    end

    class Unary < Expression
      def initialize(expression)
        @expression = wrap_xpath(expression)
      end
    end

    class Binary < Expression
      def initialize(left, right)
        @left = wrap_xpath(left)
        @right = wrap_xpath(right)
      end
    end

    class Literal < Expression
      def initialize(expression)
        @expression = expression
      end

      def to_xpath
        @expression.to_s
      end
    end

    class Child < Binary
      def to_xpath
        "#{@left.to_xpath}/#{@right.to_xpath}"
      end
    end

    class Descendant < Binary
      def to_xpath
        "#{@left.to_xpath}//#{@right.to_xpath}"
      end
    end

    class Anywhere < Unary
      def to_xpath
        "//#{@expression.to_xpath}"
      end
    end

    class Where < Binary
      def to_xpath
        "#{@left.to_xpath}[#{@right.to_xpath}]"
      end
    end

    class Attribute < Binary
      def to_xpath
        if @right.is_a?(Literal)
          "#{@left.to_xpath}/@#{@right.to_xpath}"
        else
          "#{@left.to_xpath}/attribute::node()[name(.) = #{@right.to_xpath}]"
        end
      end
    end

    class Equality < Binary
      def to_xpath
        "#{@left.to_xpath} = #{@right.to_xpath}"
      end
    end

    class StringFunction < Unary
      def to_xpath
        "string(#{@expression.to_xpath})"
      end
    end

    class StringLiteral < Expression
      def initialize(expression)
        @expression = expression
      end

      def to_xpath
        if @expression.include?("'")
          @expression = @expression.split("'", -1).map do |substr|
            "'#{substr}'"
          end.join(%q{,"'",})
          "concat(#{@expression})"
        else
          "'#{@expression}'"
        end
      end
    end

    class And < Binary
      def to_xpath
        "#{@left.to_xpath} and #{@right.to_xpath}"
      end
    end

    class Or < Binary
      def to_xpath
        "#{@left.to_xpath} or #{@right.to_xpath}"
      end
    end

    class OneOf < Expression
      def initialize(left, right)
        @left = wrap_xpath(left)
        @right = right.map { |r| wrap_xpath(r) }
      end

      def to_xpath
        @right.map { |r| "#{@left.to_xpath} = #{r.to_xpath}" }.join(' or ')
      end
    end

    class Contains < Binary
      def to_xpath
        "contains(#{@left.to_xpath}, #{@right.to_xpath})"
      end
    end

    class Text < Unary
      def to_xpath
        "#{@expression.to_xpath}/text()"
      end
    end

    class Variable < Expression
      def initialize(name)
        @name = name
      end

      def to_xpath
        "%{#{@name}}"
      end
    end


    class Applied < Expression
      def initialize(expression, variables={})
        @variables = variables
        @xpath ||= expression.to_xpath
      end

      def to_xpath
        @xpath % @variables
      rescue ArgumentError # for ruby < 1.9 compat
        @xpath.gsub(/%\{(\w+)\}/) do |_|
          @variables[$1.to_sym] or raise(ArgumentError, "expected variable #{$1} to be set")
        end
      end
    end

    def current
      self
    end

    def where(expression)
      Expression::Where.new(current, expression)
    end
    alias_method :[], :where

    def one_of(*expressions)
      Expression::OneOf.new(current, expressions)
    end

    def equals(expression)
      Expression::Equality.new(current, expression)
    end
    alias_method :==, :equals

    def or(expression)
      Expression::Or.new(current, expression)
    end
    alias_method :|, :or

    def and(expression)
      Expression::And.new(current, expression)
    end
    alias_method :&, :and

    def string_literal
      Expression::StringLiteral.new(self.to_xpath)
    end

    def to_xpath
      raise NotImplementedError, "please implement in subclass"
    end
    alias_method :to_s, :to_xpath

    def apply(variables={})
      Expression::Applied.new(current, variables)
    end

    def wrap_xpath(expression)
      case expression
        when ::String then Expression::StringLiteral.new(expression)
        when ::Symbol then Expression::Literal.new(expression)
        else expression
      end
    end
  end
end

