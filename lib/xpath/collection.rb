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
  end
end
