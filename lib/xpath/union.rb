module XPath
  class Union
    include Enumerable

    attr_reader :expressions
    alias_method :arguments, :expressions

    def initialize(*expressions)
      @expressions = expressions
    end

    def expression
      :union
    end

    def each(&block)
      arguments.each(&block)
    end

    def method_missing(*args)
      XPath::Union.new(*arguments.map { |e| e.send(*args) })
    end

    def to_xpath
      Renderer.render(self)
    end
    alias_method :to_s, :to_xpath
  end
end
