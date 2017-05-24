module XPath
  class Renderer
    def self.render(node, type)
      new(type).render(node)
    end

    def initialize(type)
      @type = type
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

    def axis(current, name, element_names)
      if element_names.length == 1
        "#{current}/#{name}::#{element_names.first}"
      elsif element_names.length > 1
        "#{current}/#{name}::*[#{element_names.map { |e| "self::#{e}" }.join(" | ")}]"
      else
        "#{current}/#{name}::*"
      end
    end

    def anywhere(element_names)
      if element_names.length == 1
        "//#{element_names.first}"
      elsif element_names.length > 1
        "//*[#{element_names.map { |e| "self::#{e}" }.join(" | ")}]"
      else
        "//*"
      end
    end

    def where(on, condition)
      "#{on}[#{condition}]"
    end

    def attribute(current, name)
      "#{current}/@#{name}"
    end

    def binary_operator(name, left, right)
      "(#{left} #{name} #{right})"
    end

    def is(one, two)
      if @type == :exact
        binary_operator("=", one, two)
      else
        function(:contains, one, two)
      end
    end

    def variable(name)
      "%{#{name}}"
    end

    def text(current)
      "#{current}/text()"
    end

    def literal(node)
      node
    end

    def css(current, selector)
      paths = Nokogiri::CSS.xpath_for(selector).map do |xpath_selector|
        "#{current}#{xpath_selector}"
      end
      union(paths)
    end

    def union(*expressions)
      expressions.join(' | ')
    end

    def function(name, *arguments)
      "#{name.to_s.gsub("_", "-")}(#{arguments.join(", ")})"
    end
  end
end
