module XPath
  class Expression
    include XPath

    class Self < Expression
      def to_xpath(predicate=nil)
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

    class Multiple < Expression
      def initialize(left, expressions)
        @left = wrap_xpath(left)
        @expressions = expressions.map { |e| wrap_xpath(e) }
      end
    end

    class Literal < Expression
      def initialize(expression)
        @expression = expression
      end

      def to_xpath(predicate=nil)
        @expression.to_s
      end
    end

    class Child < Multiple
      def to_xpath(predicate=nil)
        if @expressions.length == 1
          "#{@left.to_xpath(predicate)}/#{@expressions.first.to_xpath(predicate)}"
        elsif @expressions.length > 1
          "#{@left.to_xpath(predicate)}/*[#{@expressions.map { |e| "self::#{e.to_xpath(predicate)}" }.join(" | ")}]"
        else
          "#{@left.to_xpath(predicate)}/*"
        end
      end
    end

    class Descendant < Multiple
      def to_xpath(predicate=nil)
        if @expressions.length == 1
          "#{@left.to_xpath(predicate)}//#{@expressions.first.to_xpath(predicate)}"
        elsif @expressions.length > 1
          "#{@left.to_xpath(predicate)}//*[#{@expressions.map { |e| "self::#{e.to_xpath(predicate)}" }.join(" | ")}]"
        else
          "#{@left.to_xpath(predicate)}//*"
        end
      end
    end

    class NextSibling < Multiple
      def to_xpath(predicate=nil)
        if @expressions.length == 1
          "#{@left.to_xpath(predicate)}/following-sibling::*[1]/self::#{@expressions.first.to_xpath(predicate)}"
        elsif @expressions.length > 1
          "#{@left.to_xpath(predicate)}/following-sibling::*[1]/self::*[#{@expressions.map { |e| "self::#{e.to_xpath(predicate)}" }.join(" | ")}]"
        else
          "#{@left.to_xpath(predicate)}/following-sibling::*[1]/self::*"
        end
      end
    end

    class Tag < Unary
      def to_xpath(predicate=nil)
        "self::#{@expression.to_xpath(predicate)}"
      end
    end

    class Anywhere < Unary
      def to_xpath(predicate=nil)
        "//#{@expression.to_xpath(predicate)}"
      end
    end

    class Name < Unary
      def to_xpath(predicate=nil)
        "name(#{@expression.to_xpath(predicate)})"
      end
    end

    class Where < Binary
      def to_xpath(predicate=nil)
        "#{@left.to_xpath(predicate)}[#{@right.to_xpath(predicate)}]"
      end
    end

    class Attribute < Binary
      def to_xpath(predicate=nil)
        if @right.is_a?(Literal)
          "#{@left.to_xpath(predicate)}/@#{@right.to_xpath(predicate)}"
        else
          "#{@left.to_xpath(predicate)}/attribute::node()[name(.) = #{@right.to_xpath(predicate)}]"
        end
      end
    end

    class Equality < Binary
      def to_xpath(predicate=nil)
        "#{@left.to_xpath(predicate)} = #{@right.to_xpath(predicate)}"
      end
    end

    class StringFunction < Unary
      def to_xpath(predicate=nil)
        "string(#{@expression.to_xpath(predicate)})"
      end
    end

    class StringLiteral < Expression
      def initialize(expression)
        @expression = expression
      end

      def to_xpath(predicate=nil)
        string = @expression
        string = @expression.to_xpath(predicate) unless @expression.is_a?(String)
        if string.include?("'")
          string = string.split("'", -1).map do |substr|
            "'#{substr}'"
          end.join(%q{,"'",})
          "concat(#{string})"
        else
          "'#{string}'"
        end
      end
    end

    class NormalizedSpace < Unary
      def to_xpath(predicate=nil)
        "normalize-space(#{@expression.to_xpath(predicate)})"
      end
    end

    class And < Binary
      def to_xpath(predicate=nil)
        "(#{@left.to_xpath(predicate)} and #{@right.to_xpath(predicate)})"
      end
    end

    class Or < Binary
      def to_xpath(predicate=nil)
        "(#{@left.to_xpath(predicate)} or #{@right.to_xpath(predicate)})"
      end
    end

    class OneOf < Expression
      def initialize(left, right)
        @left = wrap_xpath(left)
        @right = right.map { |r| wrap_xpath(r) }
      end

      def to_xpath(predicate=nil)
        @right.map { |r| "#{@left.to_xpath(predicate)} = #{r.to_xpath(predicate)}" }.join(' or ')
      end
    end

    class Contains < Binary
      def to_xpath(predicate=nil)
        "contains(#{@left.to_xpath(predicate)}, #{@right.to_xpath(predicate)})"
      end
    end

    class Is < Binary
      def to_xpath(predicate=nil)
        if predicate == :exact
          Equality.new(@left, @right).to_xpath(predicate)
        else
          Contains.new(@left, @right).to_xpath(predicate)
        end
      end
    end

    class Text < Unary
      def to_xpath(predicate=nil)
        "#{@expression.to_xpath(predicate)}/text()"
      end
    end

    class Variable < Expression
      def initialize(name)
        @name = name
      end

      def to_xpath(predicate=nil)
        "%{#{@name}}"
      end
    end

    class Inverse < Unary
      def to_xpath(predicate=nil)
        "not(#{@expression.to_xpath(predicate)})"
      end
    end

    class Applied < Expression
      def initialize(expression, variables={})
        @variables = variables
        @expression = expression
      end

      def to_xpath(predicate=nil)
        @expression.to_xpath(predicate) % @variables
      rescue ArgumentError # for ruby < 1.9 compat
        @expression.to_xpath(predicate).gsub(/%\{(\w+)\}/) do |_|
          @variables[$1.to_sym] or raise(ArgumentError, "expected variable #{$1} to be set")
        end
      end
    end

    class CSS < Binary
      def to_xpath(predicate=nil)
        "#{@left.to_xpath}#{@right.to_xpath}"
      end
    end

    def current
      self
    end

    def next_sibling(*expressions)
      Expression::NextSibling.new(current, expressions)
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

    def is(expression)
      Expression::Is.new(current, expression)
    end

    def or(expression)
      Expression::Or.new(current, expression)
    end
    alias_method :|, :or

    def and(expression)
      Expression::And.new(current, expression)
    end
    alias_method :&, :and

    def union(*expressions)
      Union.new(*[self, expressions].flatten)
    end
    alias_method :+, :union

    def inverse
      Expression::Inverse.new(current)
    end
    alias_method :~, :inverse

    def string_literal
      Expression::StringLiteral.new(self)
    end

    def to_xpath(predicate=nil)
      raise NotImplementedError, "please implement in subclass"
    end

    def to_s
      to_xpaths.join(' | ')
    end

    def to_xpaths
      [to_xpath(:exact), to_xpath(:fuzzy)].uniq
    end

    def apply(variables={})
      Expression::Applied.new(current, variables)
    end

    def normalize
      Expression::NormalizedSpace.new(current)
    end
    alias_method :n, :normalize

    def wrap_xpath(expression)
      case expression
        when ::String then Expression::StringLiteral.new(expression)
        when ::Symbol then Expression::Literal.new(expression)
        else expression
      end
    end
  end
end

