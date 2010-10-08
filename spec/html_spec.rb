require 'spec_helper'
require 'nokogiri'

describe XPath::HTML do
  let(:template) { 'form' }
  let(:template_path) { File.read(File.expand_path("fixtures/#{template}.html", File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template_path) }

  def get(*args)
    all(*args).first
  end

  def all(*args)
    XPath::HTML.send(subject, *args).to_xpaths.map do |xpath|
      doc.xpath(xpath)
    end.flatten.uniq.map { |node| node[:data] }
  end

  describe '#link' do
    subject { :link }

    it("finds links by id")                                { get('some-id').should == 'link-id' }
    it("finds links by content")                           { get('An awesome link').should == 'link-text' }
    it("finds links by content regardless of whitespace")  { get('My whitespaced link').should == 'link-whitespace' }
    it("finds links with child tags by content")           { get('An emphatic link').should == 'link-children' }
    it("finds links by the content of theur child tags")   { get('emphatic').should == 'link-children' }
    it("finds links by approximate content")               { get('awesome').should == 'link-text' }
    it("prefers exact matches of content")                 { all('A link').should == ['link-exact', 'link-fuzzy'] }
    it("finds links by title")                             { get('My title').should == 'link-title' }
    it("finds links by approximate title")                 { get('title').should == 'link-title' }
    it("prefers exact matches of title")                   { all('This title').should == ['link-exact', 'link-fuzzy'] }
    it("finds links by image's alt attribute")             { get('Alt link').should == 'link-img' }
    it("finds links by image's approximate alt attribute") { get('Alt').should == 'link-img' }
    it("prefers exact matches of image's alt attribute")   { all('An image').should == ['link-img-exact', 'link-img-fuzzy'] }
    it("does not find links without href attriutes")       { get('Wrong Link').should be_nil }
  end

  describe '#button' do
    subject { :button }

    context "with submit type" do
      it("finds buttons by id")                { get('submit-with-id').should == 'id-submit' }
      it("finds buttons by value")             { get('submit-with-value').should == 'value-submit' }
      it("finds buttons by approximate value") { get('mit-with-val').should == 'value-submit' }
      it("prefers buttons with exact value")   { all('exact value submit').should == ['exact-value-submit', 'not-exact-value-submit'] }
    end

    context "with button type" do
      it("finds buttons by id")                { get('button-with-id').should == 'id-button' }
      it("finds buttons by value")             { get('button-with-value').should == 'value-button' }
      it("finds buttons by approximate value") { get('ton-with-val').should == 'value-button' }
      it("prefers buttons with exact value")   { all('exact value button').should == ['exact-value-button', 'not-exact-value-button'] }
    end

    context "with image type" do
      it("finds buttons by id")                { get('imgbut-with-id').should == 'id-imgbut' }
      it("finds buttons by value")             { get('imgbut-with-value').should == 'value-imgbut' }
      it("finds buttons by approximate value") { get('gbut-with-val').should == 'value-imgbut' }
      it("finds buttons by alt attribute")     { get('imgbut-with-alt').should == 'alt-imgbut' }
      it("prefers buttons with exact value")   { all('exact value imgbut').should == ['exact-value-imgbut', 'not-exact-value-imgbut'] }
    end

    context "with button tag" do
      it("finds buttons by id")                       { get('btag-with-id').should == 'id-btag' }
      it("finds buttons by value")                    { get('btag-with-value').should == 'value-btag' }
      it("finds buttons by approximate value")        { get('tag-with-val').should == 'value-btag' }
      it("finds prefers buttons with exact value")    { all('exact value btag').should == ['exact-value-btag', 'not-exact-value-btag'] }
      it("finds buttons by text")                     { get('btag-with-text').should == 'text-btag' }
      it("finds buttons by text ignoring whitespace") { get('My whitespaced button').should == 'btag-with-whitespace' }
      it("finds buttons by approximate text ")        { get('tag-with-tex').should == 'text-btag' }
      it("finds buttons with child tags by text")     { get('An emphatic button').should == 'btag-with-children' }
      it("finds buttons by text of their children")   { get('emphatic').should == 'btag-with-children' }
      it("prefers buttons with exact text")           { all('exact text btag').should == ['exact-text-btag', 'not-exact-text-btag'] }
    end

    context "with unkown type" do
      it("does not find the button") { get('schmoo button').should be_nil }
    end
  end
end
