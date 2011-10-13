module XPath
  class Union
    include Enumerable
    include Convertable

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
  end
end
