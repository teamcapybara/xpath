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

    class Where < Binary
      def to_xpath
        "#{@left.to_xpath}[#{@right.to_xpath}]"
      end
    end

    class Attribute < Unary
      def to_xpath
        "attribute::#{@expression.to_xpath}"
      end
    end

    class Equality < Binary
      def to_xpath
        "#{@left.to_xpath} = #{@right.to_xpath}"
      end
    end

    class String < Expression
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

    def descendant(expression)
      Expression::Descendant.new(self, expression)
    end

    def attr(expression)
      Expression::Attribute.new(expression)
    end

    def to_xpath
      raise NotImplementedError, "please implement in subclass"
    end

    def wrap(expression)
      case expression
        when ::String then Expression::String.new(expression)
        when ::Symbol then Expression::Literal.new(expression)
        else expression
      end
      
    end
  end
end
