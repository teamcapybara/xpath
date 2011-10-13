require 'nokogiri'

module XPath
  autoload :Expression, 'xpath/expression'
  autoload :Union, 'xpath/union'
  autoload :HTML, 'xpath/html'

  extend self

  def self.generate
    yield(Expression.new(:this_node))
  end

  module AdditionalStuff
    def where(expression)
      Expression.new(:where, current, expression)
    end
    alias_method :[], :where

    def next_sibling(*expressions)
      Expression.new(:next_sibling, current, expressions)
    end

    def one_of(*expressions)
      Expression.new(:one_of, current, expressions)
    end

    def equals(expression)
      Expression.new(:equality, current, expression)
    end
    alias_method :==, :equals

    def is(expression)
      Expression.new(:is, current, expression)
    end

    def or(expression)
      Expression.new(:or, current, expression)
    end
    alias_method :|, :or

    def and(expression)
      Expression.new(:and, current, expression)
    end
    alias_method :&, :and

    def union(*expressions)
      Union.new(*[self, expressions].flatten)
    end
    alias_method :+, :union

    def inverse
      Expression.new(:inverse, current)
    end
    alias_method :~, :inverse

    def string_literal
      Expression.new(:string_literal, self)
    end

    def apply(variables={})
      Expression.new(:applied, current, NewLiteral.new(variables))
    end

    def normalize
      Expression.new(:normalized_space, current)
    end
    alias_method :n, :normalize
  end

  class NewLiteral
    attr_reader :value
    def initialize(value)
      @value = value
    end
  end

  module Convertable
    def to_s
      to_xpaths.join(' | ')
    end

    def to_xpaths
      [to_xpath(:exact), to_xpath(:fuzzy)].uniq
    end

    def to_xpath(predicate=nil)
      Renderer.render(predicate, self)
    end
  end

  class Renderer
    attr_reader :predicate

    def self.render(predicate, node)
      new(predicate).render(node)
    end

    def initialize(predicate)
      @predicate = predicate
    end

    def render(node)
      arguments = node.arguments.map { |argument| convert_argument(argument) }
      send(node.expression, *arguments)
    end

    def convert_argument(argument)
      case argument
        when Expression, Union then render(argument)
        when Array then argument.map { |element| convert_argument(element) }
        when String then string_literal(argument)
        when NewLiteral then argument.value
        else argument.to_s
      end
    end

    def string_literal(string)
      if string.include?("'")
        string = string.split("'", -1).map do |substr|
          "'#{substr}'"
        end.join(%q{,"'",})
        "concat(#{string})"
      else
        "'#{string}'"
      end
    end

    def this_node
      '.'
    end

    def descendant(parent, element_names)
      if element_names.length == 1
        "#{parent}//#{element_names.first}"
      elsif element_names.length > 1
        "#{parent}//*[#{element_names.map { |e| "self::#{e}" }.join(" | ")}]"
      else
        "#{parent}//*"
      end
    end

    def child(parent, element_names)
      if element_names.length == 1
        "#{parent}/#{element_names.first}"
      elsif element_names.length > 1
        "#{parent}/*[#{element_names.map { |e| "self::#{e}" }.join(" | ")}]"
      else
        "#{parent}/*"
      end
    end

    def node_name(current)
      "name(#{current})"
    end

    def where(on, condition)
      "#{on}[#{condition}]"
    end

    def attribute(current, name)
      "#{current}/@#{name}"
    end

    def equality(one, two)
      "#{one} = #{two}"
    end

    def variable(name)
      "%{#{name}}"
    end

    def applied(expression, variables)
      expression % variables
    rescue ArgumentError # for ruby < 1.9 compat
      expression.gsub(/%\{(\w+)\}/) do |_|
        variables[$1.to_sym] or raise(ArgumentError, "expected variable #{$1} to be set")
      end
    end

    def text(current)
      "#{current}/text()"
    end

    def normalized_space(current)
      "normalize-space(#{current})"
    end

    def literal(node)
      node
    end

    def css(current, selector)
      paths = Nokogiri::CSS.xpath_for(selector).map do |selector|
        "#{current}#{selector}"
      end
      union(paths)
    end

    def union(*expressions)
      expressions.join(' | ')
    end

    def anywhere(tag_name)
      "//#{tag_name}"
    end

    def contains(current, value)
      "contains(#{current}, #{value})"
    end

    def and(one, two)
      "(#{one} and #{two})"

    end

    def or(one, two)
      "(#{one} or #{two})"
    end

    def one_of(current, values)
      values.map { |value| "#{current} = #{value}" }.join(' or ')
    end

    def is(one, two)
      if predicate == :exact
        equality(one, two)
      else
        contains(one, two)
      end
    end

    def next_sibling(current, element_names)
      if element_names.length == 1
        "#{current}/following-sibling::*[1]/self::#{element_names.first}"
      elsif element_names.length > 1
        "#{current}/following-sibling::*[1]/self::*[#{element_names.map { |e| "self::#{e}" }.join(" | ")}]"
      else
        "#{current}/following-sibling::*[1]/self::*"
      end
    end

    def inverse(current)
      "not(#{current})"
    end

    def tag(current)
      "self::#{current}"
    end

    def string_function(current)
      "string(#{current})"
    end
  end

  def current
    #Expression::Self.new
    Expression.new(:this_node)
  end

  def name
    Expression.new(:node_name, current)
  end

  def descendant(*expressions)
    Expression.new(:descendant, current, expressions)
  end

  def child(*expressions)
    Expression.new(:child, current, expressions)
  end

  def anywhere(expression)
    Expression.new(:anywhere, expression)
  end

  def attr(expression)
    Expression.new(:attribute, current, expression)
  end

  def contains(expression)
    Expression.new(:contains, current, expression)
  end

  def text
    Expression.new(:text, current)
  end

  def var(name)
    Expression.new(:variable, name)
  end

  def string
    Expression.new(:string_function, current)
  end

  def tag(name)
    Expression.new(:tag, name)
  end

  def css(selector)
    Expression.new(:css, current, NewLiteral.new(selector))
  end

  def varstring(name)
    var(name).string_literal
  end
end
