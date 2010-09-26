require 'spec_helper'
require 'nokogiri'

describe XPath::HTML do
  let(:template) { 'form' }
  let(:template_path) { File.read(File.expand_path("fixtures/#{template}.html", File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template_path) }

  def get(xpath)
    all(xpath).first
  end

  def all(xpath)
    xpath.to_xpaths.map do |xpath|
      doc.xpath(xpath)
    end.flatten
  end

  describe '#link' do
    it "finds links by id" do
      get(XPath::HTML.link('some-id'))[:href].should == '#id'
    end

    it "finds links by content" do
      get(XPath::HTML.link('An awesome link'))[:href].should == '#link'
    end

    it "finds links by content without caring about whitespace" do
      get(XPath::HTML.link('My whitespaced link'))[:href].should == '#spacey'
    end

    it "finds links with child tags by content" do
      get(XPath::HTML.link('An emphatic link'))[:href].should == '#has-children'
      get(XPath::HTML.link('emphatic'))[:href].should == '#has-children'
    end

    it "finds links by approximate content" do
      get(XPath::HTML.link('awesome'))[:href].should == '#link'
    end

    it "prefers exact matches of content" do
      result = all(XPath::HTML.link('A link'))
      result[0][:href].should == '#foo'
      result[1][:href].should == '#bar'
    end

    it "finds links by title" do
      get(XPath::HTML.link('My title'))[:href].should == '#title'
    end

    it "finds links by approximate title" do
      get(XPath::HTML.link('title'))[:href].should == '#title'
    end

    it "prefers exact matches of title" do
      result = all(XPath::HTML.link('This title'))
      result[0][:href].should == '#foo'
      result[1][:href].should == '#bar'
    end

    it "finds links by an image's alt attribute" do
      get(XPath::HTML.link('Alt link'))[:href].should == '#image'
    end

    it "finds links by an image's approximate alt attribute" do
      get(XPath::HTML.link('Alt'))[:href].should == '#image'
    end

    it "prefers exact matches of image's alt attribute" do
      result = all(XPath::HTML.link('An image'))
      result[0][:href].should == '#foo'
      result[1][:href].should == '#bar'
    end

    it "does not find links without href attriutes" do
      get(XPath::HTML.link('Wrong Link')).should be_nil
    end

  end
end
