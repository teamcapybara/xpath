module XPath
  def self.generate
    yield(Expression::Self.new).to_xpath
  end

  class Expression
    class Self < Expression
      def to_xpath
        '.'
      end
    end

    class Unary < Expression
      def initialize(expression)
        @expression = wrap(expression)
      end
    end

    class Binary < Expression
      def initialize(left, right)
        @left = wrap(left)
        @right = wrap(right)
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

    def where(expression)
      Expression::Where.new(self, expression)
    end

    def equals(expression)
      Expression::Equality.new(self, expression)
    end
    alias_method :==, :equals

    def descendant(expression)
      Expression::Descendant.new(self, expression)
    end

    def anywhere(expression)
      Expression::Anywhere.new(expression)
    end

    def attr(expression)
      Expression::Attribute.new(self, expression)
    end

    def string
      Expression::StringFunction.new(self)
    end

    def to_xpath
      raise NotImplementedError, "please implement in subclass"
    end

    def wrap(expression)
      case expression
        when ::String then Expression::StringLiteral.new(expression)
        when ::Symbol then Expression::Literal.new(expression)
        else expression
      end
      
    end
  end
end
