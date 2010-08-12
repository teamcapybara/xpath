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

    def to_xpath(predicate=nil)
      expressions.map { |e| e.to_xpath(predicate) }.join(' | ')
    end

    def to_xpaths
      [to_xpath(:exact), to_xpath(:fuzzy)].uniq
    end

    def method_missing(*args)
      XPath::Collection.new(*expressions.map { |e| e.send(*args) })
    end
  end
end
