module XPath
  autoload :Expression, 'xpath/expression'
  autoload :Collection, 'xpath/collection'

  extend self

  def self.generate
    yield(Expression::Self.new)
  end

  def current
    Expression::Self.new
  end

  def name
    Expression::Name.new(current)
  end

  def descendant(*expressions)
    Expression::Descendant.new(current, expressions)
  end

  def child(*expressions)
    Expression::Child.new(current, expressions)
  end

  def anywhere(expression)
    Expression::Anywhere.new(expression)
  end

  def attr(expression)
    Expression::Attribute.new(current, expression)
  end

  def contains(expression)
    Expression::Contains.new(current, expression)
  end

  def text
    Expression::Text.new(current)
  end

  def var(name)
    Expression::Variable.new(name)
  end

  def varstring(name)
    var(name).string_literal
  end
end
