module XPath
  class Collection
    include Enumerable

    attr_reader :expressions

    def initialize(*expressions)
      @expressions = expressions
    end

    def each(&block)
      expressions.each(&block)
    end

    def to_xpath
      expressions.map { |e| e.to_xpath }.join(' | ')
    end

    def method_missing(*args)
      XPath::Collection.new(*expressions.map { |e| e.send(*args) })
    end
  end
end
