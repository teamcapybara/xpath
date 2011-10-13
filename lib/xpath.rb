require 'nokogiri'

module XPath
  autoload :Expression, 'xpath/expression'
  autoload :Literal, 'xpath/literal'
  autoload :Convertable, 'xpath/convertable'
  autoload :Union, 'xpath/union'
  autoload :Renderer, 'xpath/renderer'
  autoload :HTML, 'xpath/html'
  autoload :DSL, 'xpath/dsl'

  extend XPath::DSL::TopLevel
  include XPath::DSL::TopLevel

  def self.generate
    yield(Expression.new(:this_node))
  end
end
