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
      get(XPath::HTML.link('some-id'))[:data].should == 'link-id'
    end

    it "finds links by content" do
      get(XPath::HTML.link('An awesome link'))[:data].should == 'link-text'
    end

    it "finds links by content without caring about whitespace" do
      get(XPath::HTML.link('My whitespaced link'))[:data].should == 'link-whitespace'
    end

    it "finds links with child tags by content" do
      get(XPath::HTML.link('An emphatic link'))[:data].should == 'link-children'
      get(XPath::HTML.link('emphatic'))[:data].should == 'link-children'
    end

    it "finds links by approximate content" do
      get(XPath::HTML.link('awesome'))[:data].should == 'link-text'
    end

    it "prefers exact matches of content" do
      result = all(XPath::HTML.link('A link'))
      result[0][:data].should == 'link-exact'
      result[1][:data].should == 'link-fuzzy'
    end

    it "finds links by title" do
      get(XPath::HTML.link('My title'))[:data].should == 'link-title'
    end

    it "finds links by approximate title" do
      get(XPath::HTML.link('title'))[:data].should == 'link-title'
    end

    it "prefers exact matches of title" do
      result = all(XPath::HTML.link('This title'))
      result[0][:data].should == 'link-exact'
      result[1][:data].should == 'link-fuzzy'
    end

    it "finds links by an image's alt attribute" do
      get(XPath::HTML.link('Alt link'))[:data].should == 'link-img'
    end

    it "finds links by an image's approximate alt attribute" do
      get(XPath::HTML.link('Alt'))[:data].should == 'link-img'
    end

    it "prefers exact matches of image's alt attribute" do
      result = all(XPath::HTML.link('An image'))
      result[0][:data].should == 'link-img-exact'
      result[1][:data].should == 'link-img-fuzzy'
    end

    it "does not find links without href attriutes" do
      get(XPath::HTML.link('Wrong Link')).should be_nil
    end
  end

  describe '#button' do
    context "with submit type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('submit-with-id'))[:data].should == 'id-submit'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('submit-with-value'))[:data].should == 'value-submit'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('mit-with-val'))[:data].should == 'value-submit'
      end

      it "finds prefers buttons with exact value " do
        results = all(XPath::HTML.button('exact value submit'))
        results[0][:data].should == 'exact-value-submit'
        results[1][:data].should == 'not-exact-value-submit'
      end
    end

    context "with button type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('button-with-id'))[:data].should == 'id-button'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('button-with-value'))[:data].should == 'value-button'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('ton-with-val'))[:data].should == 'value-button'
      end

      it "finds prefers buttons with exact value " do
        results = all(XPath::HTML.button('exact value button'))
        results[0][:data].should == 'exact-value-button'
        results[1][:data].should == 'not-exact-value-button'
      end
    end

    context "with image type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('imgbut-with-id'))[:data].should == 'id-imgbut'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('imgbut-with-value'))[:data].should == 'value-imgbut'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('gbut-with-val'))[:data].should == 'value-imgbut'
      end

      it "finds buttons by alt attribute" do
        get(XPath::HTML.button('imgbut-with-alt'))[:data].should == 'alt-imgbut'
      end

      it "prefers buttons with exact value " do
        results = all(XPath::HTML.button('exact value imgbut'))
        results[0][:data].should == 'exact-value-imgbut'
        results[1][:data].should == 'not-exact-value-imgbut'
      end
    end

    context "with button tag" do
      it "finds buttons by id" do
        get(XPath::HTML.button('btag-with-id'))[:data].should == 'id-btag'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('btag-with-value'))[:data].should == 'value-btag'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('tag-with-val'))[:data].should == 'value-btag'
      end

      it "finds prefers buttons with exact value " do
        results = all(XPath::HTML.button('exact value btag'))
        results[0][:data].should == 'exact-value-btag'
        results[1][:data].should == 'not-exact-value-btag'
      end

      it "finds buttons by text" do
        get(XPath::HTML.button('btag-with-text'))[:data].should == 'text-btag'
      end

      it "finds buttons by text ignoring whitespace" do
        get(XPath::HTML.button('My whitespaced button'))[:data].should == 'btag-with-whitespace'
      end

      it "finds buttons by approximate text " do
        get(XPath::HTML.button('tag-with-tex'))[:data].should == 'text-btag'
      end

      it "finds buttons with child tags by text" do
        get(XPath::HTML.button('An emphatic button'))[:data].should == 'btag-with-children'
        get(XPath::HTML.button('emphatic'))[:data].should == 'btag-with-children'
      end

      it "prefers buttons with exact text" do
        results = all(XPath::HTML.button('exact text btag'))
        results[0][:data].should == 'exact-text-btag'
        results[1][:data].should == 'not-exact-text-btag'
      end
    end

    context "with unkown type" do
      it "does not find the button" do
        get(XPath::HTML.button('schmoo button')).should be_nil
      end
    end

  end
end
