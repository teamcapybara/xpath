require 'nokogiri'

module XPath
  autoload :Expression, 'xpath/expression'
  autoload :Literal, 'xpath/literal'
  autoload :Union, 'xpath/union'
  autoload :HTML, 'xpath/html'
  autoload :DSL, 'xpath/dsl'

  extend XPath::DSL::TopLevel
  include XPath::DSL::TopLevel

  def self.generate
    yield(Expression.new(:this_node))
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
        when Literal then argument.value
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

end
