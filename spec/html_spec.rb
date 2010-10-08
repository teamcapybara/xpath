require 'spec_helper'
require 'nokogiri'

describe XPath::HTML do
  let(:template) { 'form' }
  let(:template_path) { File.read(File.expand_path("fixtures/#{template}.html", File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template_path) }

  def get(method, *args)
    all(method, *args).first
  end

  def all(method, *args)
    XPath::HTML.send(method, *args).to_xpaths.map do |xpath|
      doc.xpath(xpath)
    end.flatten.uniq.map { |node| node[:data] }
  end

  describe '#link' do
    it("finds links by id") { get(:link, 'some-id').should == 'link-id' }
    it("finds links by content") { get(:link, 'An awesome link').should == 'link-text' }
    it("finds links by content without caring about whitespace") { get(:link, 'My whitespaced link').should == 'link-whitespace' }
    it("finds links with child tags by content") { get(:link, 'An emphatic link').should == 'link-children' }
    it("finds links by the content of theur child tags") { get(:link, 'emphatic').should == 'link-children' }
    it("finds links by approximate content") { get(:link, 'awesome').should == 'link-text' }
    it("prefers exact matches of content") { all(:link, 'A link').should == ['link-exact', 'link-fuzzy'] }
    it("finds links by title") { get(:link, 'My title').should == 'link-title' }
    it("finds links by approximate title") { get(:link, 'title').should == 'link-title' }
    it("prefers exact matches of title") { all(:link, 'This title').should == ['link-exact', 'link-fuzzy'] }
    it("finds links by an image's alt attribute") { get(:link, 'Alt link').should == 'link-img' }
    it("finds links by an image's approximate alt attribute") { get(:link, 'Alt').should == 'link-img' }
    it("prefers exact matches of image's alt attribute") { all(:link, 'An image').should == ['link-img-exact', 'link-img-fuzzy'] }
    it("does not find links without href attriutes") { get(:link, 'Wrong Link').should be_nil }
  end

  describe '#button' do
    context "with submit type" do
      it("finds buttons by id") { get(:button, 'submit-with-id').should == 'id-submit' }
      it("finds buttons by value") { get(:button, 'submit-with-value').should == 'value-submit' }
      it("finds buttons by approximate value ") { get(:button, 'mit-with-val').should == 'value-submit' }
      it("finds prefers buttons with exact value ") {   all(:button, 'exact value submit').should == ['exact-value-submit', 'not-exact-value-submit'] }
    end

    context "with button type" do
      it("finds buttons by id") { get(:button, 'button-with-id').should == 'id-button' }
      it("finds buttons by value") { get(:button, 'button-with-value').should == 'value-button' }
      it("finds buttons by approximate value ") { get(:button, 'ton-with-val').should == 'value-button' }
      it("finds prefers buttons with exact value ") { all(:button, 'exact value button').should == ['exact-value-button', 'not-exact-value-button'] }
    end

    context "with image type" do
      it("finds buttons by id") { get(:button, 'imgbut-with-id').should == 'id-imgbut' }
      it("finds buttons by value") { get(:button, 'imgbut-with-value').should == 'value-imgbut' }
      it("finds buttons by approximate value ") { get(:button, 'gbut-with-val').should == 'value-imgbut' }
      it("finds buttons by alt attribute") { get(:button, 'imgbut-with-alt').should == 'alt-imgbut' }
      it("prefers buttons with exact value ") { all(:button, 'exact value imgbut').should == ['exact-value-imgbut', 'not-exact-value-imgbut'] }
    end

    context "with button tag" do
      it("finds buttons by id") { get(:button, 'btag-with-id').should == 'id-btag' }
      it("finds buttons by value") { get(:button, 'btag-with-value').should == 'value-btag' }
      it("finds buttons by approximate value ") { get(:button, 'tag-with-val').should == 'value-btag' }
      it("finds prefers buttons with exact value ") { all(:button, 'exact value btag').should == ['exact-value-btag', 'not-exact-value-btag'] }
      it("finds buttons by text") { get(:button, 'btag-with-text').should == 'text-btag' }
      it("finds buttons by text ignoring whitespace") { get(:button, 'My whitespaced button').should == 'btag-with-whitespace' }
      it("finds buttons by approximate text ") { get(:button, 'tag-with-tex').should == 'text-btag' }
      it("finds buttons with child tags by text") { get(:button, 'An emphatic button').should == 'btag-with-children' }
      it("finds buttons by the text of their child elements") { get(:button, 'emphatic').should == 'btag-with-children' }
      it("prefers buttons with exact text") { all(:button, 'exact text btag').should == ['exact-text-btag', 'not-exact-text-btag'] }
    end

    context "with unkown type" do
      it("does not find the button") { get(:button, 'schmoo button').should be_nil }
    end

  end
end
