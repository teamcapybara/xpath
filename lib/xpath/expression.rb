module XPath
  class Expression
    attr_accessor :expression, :arguments
    include XPath::DSL::ExpressionLevel

    def initialize(expression, *arguments)
      @expression = expression
      @arguments = arguments
    end

    def current
      self
    end

    def to_xpath
      Renderer.render(self)
    end
    alias_method :to_s, :to_xpath
  end
end
