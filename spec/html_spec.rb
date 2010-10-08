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
    end.flatten.uniq.map { |node| node[:data] }
  end

  describe '#link' do
    it "finds links by id" do
      get(XPath::HTML.link('some-id')).should == 'link-id'
    end

    it "finds links by content" do
      get(XPath::HTML.link('An awesome link')).should == 'link-text'
    end

    it "finds links by content without caring about whitespace" do
      get(XPath::HTML.link('My whitespaced link')).should == 'link-whitespace'
    end

    it "finds links with child tags by content" do
      get(XPath::HTML.link('An emphatic link')).should == 'link-children'
      get(XPath::HTML.link('emphatic')).should == 'link-children'
    end

    it "finds links by approximate content" do
      get(XPath::HTML.link('awesome')).should == 'link-text'
    end

    it "prefers exact matches of content" do
      all(XPath::HTML.link('A link')).should == ['link-exact', 'link-fuzzy']
    end

    it "finds links by title" do
      get(XPath::HTML.link('My title')).should == 'link-title'
    end

    it "finds links by approximate title" do
      get(XPath::HTML.link('title')).should == 'link-title'
    end

    it "prefers exact matches of title" do
      all(XPath::HTML.link('This title')).should == ['link-exact', 'link-fuzzy']
    end

    it "finds links by an image's alt attribute" do
      get(XPath::HTML.link('Alt link')).should == 'link-img'
    end

    it "finds links by an image's approximate alt attribute" do
      get(XPath::HTML.link('Alt')).should == 'link-img'
    end

    it "prefers exact matches of image's alt attribute" do
      all(XPath::HTML.link('An image')).should == ['link-img-exact', 'link-img-fuzzy']
    end

    it "does not find links without href attriutes" do
      get(XPath::HTML.link('Wrong Link')).should be_nil
    end
  end

  describe '#button' do
    context "with submit type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('submit-with-id')).should == 'id-submit'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('submit-with-value')).should == 'value-submit'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('mit-with-val')).should == 'value-submit'
      end

      it "finds prefers buttons with exact value " do
        all(XPath::HTML.button('exact value submit')).should == ['exact-value-submit', 'not-exact-value-submit']
      end
    end

    context "with button type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('button-with-id')).should == 'id-button'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('button-with-value')).should == 'value-button'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('ton-with-val')).should == 'value-button'
      end

      it "finds prefers buttons with exact value " do
        all(XPath::HTML.button('exact value button')).should == ['exact-value-button', 'not-exact-value-button']
      end
    end

    context "with image type" do
      it "finds buttons by id" do
        get(XPath::HTML.button('imgbut-with-id')).should == 'id-imgbut'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('imgbut-with-value')).should == 'value-imgbut'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('gbut-with-val')).should == 'value-imgbut'
      end

      it "finds buttons by alt attribute" do
        get(XPath::HTML.button('imgbut-with-alt')).should == 'alt-imgbut'
      end

      it "prefers buttons with exact value " do
        all(XPath::HTML.button('exact value imgbut')).should == ['exact-value-imgbut', 'not-exact-value-imgbut']
      end
    end

    context "with button tag" do
      it "finds buttons by id" do
        get(XPath::HTML.button('btag-with-id')).should == 'id-btag'
      end

      it "finds buttons by value" do
        get(XPath::HTML.button('btag-with-value')).should == 'value-btag'
      end

      it "finds buttons by approximate value " do
        get(XPath::HTML.button('tag-with-val')).should == 'value-btag'
      end

      it "finds prefers buttons with exact value " do
        all(XPath::HTML.button('exact value btag')).should == ['exact-value-btag', 'not-exact-value-btag']
      end

      it "finds buttons by text" do
        get(XPath::HTML.button('btag-with-text')).should == 'text-btag'
      end

      it "finds buttons by text ignoring whitespace" do
        get(XPath::HTML.button('My whitespaced button')).should == 'btag-with-whitespace'
      end

      it "finds buttons by approximate text " do
        get(XPath::HTML.button('tag-with-tex')).should == 'text-btag'
      end

      it "finds buttons with child tags by text" do
        get(XPath::HTML.button('An emphatic button')).should == 'btag-with-children'
        get(XPath::HTML.button('emphatic')).should == 'btag-with-children'
      end

      it "prefers buttons with exact text" do
        all(XPath::HTML.button('exact text btag')).should == ['exact-text-btag', 'not-exact-text-btag']
      end
    end

    context "with unkown type" do
      it "does not find the button" do
        get(XPath::HTML.button('schmoo button')).should be_nil
      end
    end

  end
end
