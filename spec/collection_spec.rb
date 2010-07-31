require 'spec_helper'

describe XPath::Collection do
  let(:template) { File.read(File.expand_path('fixtures/simple.html', File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template) }

  describe '#expressions' do
    it "should return the expressions" do
      @expr1 = XPath.generate { |x| x.descendant(:p) } 
      @expr2 = XPath.generate { |x| x.descendant(:div) } 
      @collection = XPath::Collection.new(@expr1, @expr2)
      @collection.expressions.should == [@expr1, @expr2]
    end
  end

  describe '#each' do
    it "should iterate through the expressions" do
      @expr1 = XPath.generate { |x| x.descendant(:p) } 
      @expr2 = XPath.generate { |x| x.descendant(:div) } 
      @collection = XPath::Collection.new(@expr1, @expr2)
      exprs = []
      @collection.each { |expr| exprs << expr }
      exprs.should == [@expr1, @expr2]
    end
  end

  describe '#map' do
    it "should map the expressions" do
      @expr1 = XPath.generate { |x| x.descendant(:p) } 
      @expr2 = XPath.generate { |x| x.descendant(:div) } 
      @collection = XPath::Collection.new(@expr1, @expr2)
      exprs = []
      @collection.map { |expr| expr.class }.should == [XPath::Expression::Descendant, XPath::Expression::Descendant]
    end
  end
end

