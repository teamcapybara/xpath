module XPath
  autoload :Expression, 'xpath/expression'
  autoload :Collection, 'xpath/collection'

  def self.generate
    yield(Expression::Self.new)
  end

  def current
    Expression::Self.new
  end

  def descendant(expression)
    Expression::Descendant.new(current, expression)
  end

  def child(expression)
    Expression::Child.new(current, expression)
  end

  def anywhere(expression)
    Expression::Anywhere.new(expression)
  end

  def attr(expression)
    Expression::Attribute.new(current, expression)
  end

  def string
    Expression::StringFunction.new(current)
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
