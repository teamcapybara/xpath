module XPath
  class Expression
    include XPath

    class Self < Expression
      def render_xpath
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

      def render_xpath
        @expression.to_s
      end
    end

    class Child < Binary
      def render_xpath
        "#{@left.to_xpath}/#{@right.to_xpath}"
      end
    end

    class Descendant < Binary
      def render_xpath
        "#{@left.to_xpath}//#{@right.to_xpath}"
      end
    end

    class Anywhere < Unary
      def render_xpath
        "//#{@expression.to_xpath}"
      end
    end

    class Where < Binary
      def render_xpath
        "#{@left.to_xpath}[#{@right.to_xpath}]"
      end
    end

    class Attribute < Binary
      def render_xpath
        if @right.is_a?(Literal)
          "#{@left.to_xpath}/@#{@right.to_xpath}"
        else
          "#{@left.to_xpath}/attribute::node()[name(.) = #{@right.to_xpath}]"
        end
      end
    end

    class Equality < Binary
      def render_xpath
        "#{@left.to_xpath} = #{@right.to_xpath}"
      end
    end

    class StringFunction < Unary
      def render_xpath
        "string(#{@expression.to_xpath})"
      end
    end

    class StringLiteral < Expression
      def initialize(expression)
        @expression = expression
      end

      def render_xpath
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
      def render_xpath
        "#{@left.to_xpath} and #{@right.to_xpath}"
      end
    end

    class Or < Binary
      def render_xpath
        "#{@left.to_xpath} or #{@right.to_xpath}"
      end
    end

    class OneOf < Expression
      def initialize(left, right)
        @left = wrap_xpath(left)
        @right = right.map { |r| wrap_xpath(r) }
      end

      def render_xpath
        @right.map { |r| "#{@left.to_xpath} = #{r.to_xpath}" }.join(' or ')
      end
    end

    class Contains < Binary
      def render_xpath
        "contains(#{@left.to_xpath}, #{@right.to_xpath})"
      end
    end

    def current
      self
    end

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

    def render_xpath
      raise NotImplementedError, "please implement in subclass"
    end

    def to_xpath
      @_render_xpath ||= render_xpath
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

