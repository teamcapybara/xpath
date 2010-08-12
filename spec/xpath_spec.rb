require 'spec_helper'

require 'nokogiri'

class Thingy
  include XPath

  def foo_div
    descendant(:div).where(attr(:id) == 'foo')
  end
end

describe XPath do
  let(:template) { File.read(File.expand_path('fixtures/simple.html', File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template) }

  def xpath(&block)
    doc.xpath XPath.generate(&block).to_xpath
  end

  it "should work as a mixin" do
    xpath = Thingy.new.foo_div.to_xpath
    doc.xpath(xpath).first[:title].should == 'fooDiv'
  end

  describe '#descendant' do
    it "should find nodes that are nested below the current node" do
      @results = xpath { |x| x.descendant(:p) }
      @results[0].text.should == "Blah"
      @results[1].text.should == "Bax"
    end

    it "should not find nodes outside the context" do
      @results = xpath do |x|
        foo_div = x.descendant(:div).where(x.attr(:id) == 'foo')
        x.descendant(:p).where(x.attr(:id) == foo_div.attr(:title))
      end
      @results[0].should be_nil
    end

    it "should find multiple kinds of nodes" do
      @results = xpath { |x| x.descendant(:p, :ul) }
      @results[0].text.should == 'Blah'
      @results[3].text.should == 'A list'
    end
  end

  describe '#child' do
    it "should find nodes that are nested directly below the current node" do
      @results = xpath { |x| x.descendant(:div).child(:p) }
      @results[0].text.should == "Blah"
      @results[1].text.should == "Bax"
    end

    it "should not find nodes that are nested further down below the current node" do
      @results = xpath { |x| x.child(:p) }
      @results[0].should be_nil
    end
  end

  describe '#anywhere' do
    it "should find nodes regardless of the context" do
      @results = xpath do |x|
        foo_div = x.anywhere(:div).where(x.attr(:id) == 'foo')
        x.descendant(:p).where(x.attr(:id) == foo_div.attr(:title))
      end
      @results[0].text.should == "Blah"
    end
  end

  describe '#contains' do
    it "should find nodes that contain the given string" do
      @results = xpath do |x|
        x.descendant(:div).where(x.attr(:title).contains('ooD'))
      end
      @results[0][:id].should == "foo"
    end

    it "should find nodes that contain the given expression" do
      @results = xpath do |x|
        expression = x.anywhere(:div).where(x.attr(:title) == 'fooDiv').attr(:id)
        x.descendant(:div).where(x.attr(:title).contains(expression))
      end
      @results[0][:id].should == "foo"
    end
  end

  describe '#text' do
    it "should select a node's text" do
      @results = xpath { |x| x.descendant(:p).where(x.text == 'Bax') }
      @results[0].text.should == 'Bax'
      @results[1][:title].should == 'monkey'
      @results = xpath { |x| x.descendant(:div).where(x.descendant(:p).text == 'Bax') }
      @results[0][:title].should == 'fooDiv'
    end
  end

  describe '#where' do
    it "should limit the expression to find only certain nodes" do
      xpath { |x| x.descendant(:div).where(:"@id = 'foo'") }.first[:title].should == "fooDiv"
    end

    it "should be aliased as []" do
      xpath { |x| x.descendant(:div)[:"@id = 'foo'"] }.first[:title].should == "fooDiv"
    end
  end

  describe '#inverse' do
    it "should invert the expression" do
      xpath { |x| x.descendant(:p).where(x.attr(:id).equals('fooDiv').inverse) }.first.text.should == 'Bax'
    end

    it "should be aliased as the unary tilde" do
      xpath { |x| x.descendant(:p).where(~x.attr(:id).equals('fooDiv')) }.first.text.should == 'Bax'
    end
  end

  describe '#equals' do
    it "should limit the expression to find only certain nodes" do
      xpath { |x| x.descendant(:div).where(x.attr(:id).equals('foo')) }.first[:title].should == "fooDiv"
    end

    it "should be aliased as ==" do
      xpath { |x| x.descendant(:div).where(x.attr(:id) == 'foo') }.first[:title].should == "fooDiv"
    end
  end

  describe '#one_of' do
    it "should return all nodes where the condition matches" do
      @results = xpath do |x|
        p = x.anywhere(:div).where(x.attr(:id) == 'foo').attr(:title)
        x.descendant(:*).where(x.attr(:id).one_of('foo', p, 'baz'))
      end
      @results[0][:title].should == "fooDiv"
      @results[1].text.should == "Blah"
      @results[2][:title].should == "bazDiv"
    end
  end

  describe '#and' do
    it "should find all nodes in both expression" do
      @results = xpath do |x|
        x.descendant(:*).where(x.contains('Bax').and(x.attr(:title).equals('monkey')))
      end
      @results[0][:title].should == "monkey"
    end

    it "should be aliased as ampersand (&)" do
      @results = xpath do |x|
        x.descendant(:*).where(x.contains('Bax') & x.attr(:title).equals('monkey'))
      end
      @results[0][:title].should == "monkey"
    end
  end

  describe '#or' do
    it "should find all nodes in either expression" do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).equals('foo').or(x.attr(:id).equals('fooDiv')))
      end
      @results[0][:title].should == "fooDiv"
      @results[1].text.should == "Blah"
    end

    it "should be aliased as pipe (|)" do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).equals('foo') | x.attr(:id).equals('fooDiv'))
      end
      @results[0][:title].should == "fooDiv"
      @results[1].text.should == "Blah"
    end
  end

  describe '#attr' do
    it "should be an attribute" do
      @results = xpath { |x| x.descendant(:div).where(x.attr(:id)) }
      @results[0][:title].should == "barDiv"
      @results[1][:title].should == "fooDiv"
    end
    
    it "should be closed" do
      @results = xpath do |x|
        foo_div = x.anywhere(:div).where(x.attr(:id) == 'foo')
        id = x.attr(foo_div.attr(:data))
        x.descendant(:div).where(id == 'bar')
      end.first[:title].should == "barDiv"
    end
  end

  describe '#apply and #var' do
    it "should interpolate variables in the xpath expression" do
      @xpath = XPath.generate do |x|
        exp = x.descendant(:*).where(x.attr(:id) == x.var(:id).string_literal)
      end
      @result1 = doc.xpath(@xpath.apply(:id => 'foo').to_xpath).first
      @result1[:title].should == 'fooDiv'
      @result2 = doc.xpath(@xpath.apply(:id => 'baz').to_xpath).first
      @result2[:title].should == 'bazDiv'
    end

    it "should raise an argument error if the interpolation key is not given" do
      @xpath = XPath.generate { |x| x.descendant(:*).where(x.attr(:id) == x.var(:id).string_literal) }
      lambda { @xpath.apply.to_xpath }.should raise_error(ArgumentError)
    end
  end

  describe '#varstring' do
    it "should add a literal string variable" do
      @xpath = XPath.generate { |x| x.descendant(:*).where(x.attr(:id) == x.varstring(:id)) }
      @result1 = doc.xpath(@xpath.apply(:id => 'foo').to_xpath).first
      @result1[:title].should == 'fooDiv'
    end
  end

end
