module XPath
  def self.generate
    yield(Expression::Self.new).to_xpath
  end

  class Expression
    class Self < Expression
      def render
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

      def render
        @expression.to_s
      end
    end

    class Child < Binary
      def render
        "#{@left.to_xpath}/#{@right.to_xpath}"
      end
    end

    class Descendant < Binary
      def render
        "#{@left.to_xpath}//#{@right.to_xpath}"
      end
    end

    class Anywhere < Unary
      def render
        "//#{@expression.to_xpath}"
      end
    end

    class Where < Binary
      def render
        "#{@left.to_xpath}[#{@right.to_xpath}]"
      end
    end

    class Attribute < Binary
      def render
        if @right.is_a?(Literal)
          "#{@left.to_xpath}/@#{@right.to_xpath}"
        else
          "#{@left.to_xpath}/attribute::node()[name(.) = #{@right.to_xpath}]"
        end
      end
    end

    class Equality < Binary
      def render
        "#{@left.to_xpath} = #{@right.to_xpath}"
      end
    end

    class StringFunction < Unary
      def render
        "string(#{@expression.to_xpath})"
      end
    end

    class StringLiteral < Expression
      def initialize(expression)
        @expression = expression
      end

      def render
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
      def render
        "#{@left.to_xpath} and #{@right.to_xpath}"
      end
    end

    class Or < Binary
      def render
        "#{@left.to_xpath} or #{@right.to_xpath}"
      end
    end

    class OneOf < Expression
      def initialize(left, right)
        @left = wrap(left)
        @right = right.map { |r| wrap(r) }
      end

      def render
        @right.map { |r| "#{@left.to_xpath} = #{r.to_xpath}" }.join(' or ')
      end
    end

    class Contains < Binary
      def render
        "contains(#{@left.to_xpath}, #{@right.to_xpath})"
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

    def child(expression)
      Expression::Child.new(self, expression)
    end

    def anywhere(expression)
      Expression::Anywhere.new(expression)
    end

    def attr(expression)
      Expression::Attribute.new(self, expression)
    end

    def or(expression)
      Expression::Or.new(self, expression)
    end
    alias_method :|, :or

    def and(expression)
      Expression::And.new(self, expression)
    end
    alias_method :&, :and

    def one_of(*expressions)
      Expression::OneOf.new(self, expressions)
    end

    def string
      Expression::StringFunction.new(self)
    end

    def contains(expression)
      Expression::Contains.new(self, expression)
    end

    def render
      raise NotImplementedError, "please implement in subclass"
    end

    def to_xpath
      @_render ||= render
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
