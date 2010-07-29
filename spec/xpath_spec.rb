require 'spec_helper'

require 'nokogiri'

describe XPath do
  def xpath(&block)
    template = File.read(File.expand_path('fixtures/simple.html', File.dirname(__FILE__)))
    doc = Nokogiri::HTML(template)
    xpath = XPath.generate(&block)
    doc.xpath(xpath)
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

  describe '#where' do
    it "should limit the expression to find only certain nodes" do
      xpath { |x| x.descendant(:div).where(:"@id = 'foo'") }.first[:title].should == "fooDiv"
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

end
