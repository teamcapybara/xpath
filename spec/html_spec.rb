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
    it("finds links with an href")                         { get("Href-ed link", :href => 'http://www.example.com').should == 'link-href' }
    it("does not find links with an incorrect href")       { get("Href-ed link", :href => 'http://www.somewhere.com').should be_nil }
  end

  describe '#button' do
    subject { :button }

    context "with submit type" do
      it("finds buttons by id")                { get('submit-with-id').should == 'id-submit' }
      it("finds buttons by value")             { get('submit-with-value').should == 'value-submit' }
      it("finds buttons by approximate value") { get('mit-with-val').should == 'value-submit' }
      it("prefers buttons with exact value")   { all('exact value submit').should == ['exact-value-submit', 'not-exact-value-submit'] }
      it("finds buttons by title")             { get('My submit title').should == 'title-submit' }
      it("finds buttons by approximate title") { get('submit title').should == 'title-submit' }
      it("prefers exact matches of title")     { all('Exact submit title').should == ['exact-title-submit', 'not-exact-title-submit'] }
    end

    context "with button type" do
      it("finds buttons by id")                { get('button-with-id').should == 'id-button' }
      it("finds buttons by value")             { get('button-with-value').should == 'value-button' }
      it("finds buttons by approximate value") { get('ton-with-val').should == 'value-button' }
      it("prefers buttons with exact value")   { all('exact value button').should == ['exact-value-button', 'not-exact-value-button'] }
      it("finds buttons by title")             { get('My button title').should == 'title-button' }
      it("finds buttons by approximate title") { get('button title').should == 'title-button' }
      it("prefers exact matches of title")     { all('Exact button title').should == ['exact-title-button', 'not-exact-title-button'] }
    end

    context "with image type" do
      it("finds buttons by id")                { get('imgbut-with-id').should == 'id-imgbut' }
      it("finds buttons by value")             { get('imgbut-with-value').should == 'value-imgbut' }
      it("finds buttons by approximate value") { get('gbut-with-val').should == 'value-imgbut' }
      it("finds buttons by alt attribute")     { get('imgbut-with-alt').should == 'alt-imgbut' }
      it("prefers buttons with exact value")   { all('exact value imgbut').should == ['exact-value-imgbut', 'not-exact-value-imgbut'] }
      it("finds buttons by title")             { get('My imgbut title').should == 'title-imgbut' }
      it("finds buttons by approximate title") { get('imgbut title').should == 'title-imgbut' }
      it("prefers exact matches of title")     { all('Exact imgbut title').should == ['exact-title-imgbut', 'not-exact-title-imgbut'] }
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
      it("finds buttons by title")                    { get('My btag title').should == 'title-btag' }
      it("finds buttons by approximate title")        { get('btag title').should == 'title-btag' }
      it("prefers exact matches of title")            { all('Exact btag title').should == ['exact-title-btag', 'not-exact-title-btag'] }
    end

    context "with unkown type" do
      it("does not find the button") { get('schmoo button').should be_nil }
    end
  end

  describe '#fieldset' do
    subject { :fieldset }

    it("finds fieldsets by id")                  { get('some-fieldset-id').should == 'fieldset-id' }
    it("finds fieldsets by legend")              { get('Some Legend').should == 'fieldset-legend' }
    it("finds fieldsets by legend child tags")   { get('Span Legend').should == 'fieldset-legend-span' }
    it("accepts approximate legends")            { get('Legend').should == 'fieldset-legend' }
    it("prefers exact legend")                   { all('Long legend').should == ['fieldset-exact', 'fieldset-fuzzy'] }
  end

  describe '#field' do
    subject { :field }

    context "by id" do
      it("finds inputs with no type")       { get('input-with-id').should == 'input-with-id-data' }
      it("finds inputs with text type")     { get('input-text-with-id').should == 'input-text-with-id-data' }
      it("finds inputs with password type") { get('input-password-with-id').should == 'input-password-with-id-data' }
      it("finds inputs with custom type")   { get('input-custom-with-id').should == 'input-custom-with-id-data' }
      it("finds textareas")                 { get('textarea-with-id').should == 'textarea-with-id-data' }
      it("finds select boxes")              { get('select-with-id').should == 'select-with-id-data' }
      it("does not find submit buttons")    { get('input-submit-with-id').should be_nil }
      it("does not find image buttons")     { get('input-image-with-id').should be_nil }
      it("does not find hidden fields")     { get('input-hidden-with-id').should be_nil }
    end

    context "by name" do
      it("finds inputs with no type")       { get('input-with-name').should == 'input-with-name-data' }
      it("finds inputs with text type")     { get('input-text-with-name').should == 'input-text-with-name-data' }
      it("finds inputs with password type") { get('input-password-with-name').should == 'input-password-with-name-data' }
      it("finds inputs with custom type")   { get('input-custom-with-name').should == 'input-custom-with-name-data' }
      it("finds textareas")                 { get('textarea-with-name').should == 'textarea-with-name-data' }
      it("finds select boxes")              { get('select-with-name').should == 'select-with-name-data' }
      it("does not find submit buttons")    { get('input-submit-with-name').should be_nil }
      it("does not find image buttons")     { get('input-image-with-name').should be_nil }
      it("does not find hidden fields")     { get('input-hidden-with-name').should be_nil }
    end

    context "by referenced label" do
      it("finds inputs with no type")       { get('Input with label').should == 'input-with-label-data' }
      it("finds inputs with text type")     { get('Input text with label').should == 'input-text-with-label-data' }
      it("finds inputs with password type") { get('Input password with label').should == 'input-password-with-label-data' }
      it("finds inputs with custom type")   { get('Input custom with label').should == 'input-custom-with-label-data' }
      it("finds textareas")                 { get('Textarea with label').should == 'textarea-with-label-data' }
      it("finds select boxes")              { get('Select with label').should == 'select-with-label-data' }
      it("does not find submit buttons")    { get('Input submit with label').should be_nil }
      it("does not find image buttons")     { get('Input image with label').should be_nil }
      it("does not find hidden fields")     { get('Input hidden with label').should be_nil }
    end

    context "by parent label" do
      it("finds inputs with no type")       { get('Input with parent label').should == 'input-with-parent-label-data' }
      it("finds inputs with text type")     { get('Input text with parent label').should == 'input-text-with-parent-label-data' }
      it("finds inputs with password type") { get('Input password with parent label').should == 'input-password-with-parent-label-data' }
      it("finds inputs with custom type")   { get('Input custom with parent label').should == 'input-custom-with-parent-label-data' }
      it("finds textareas")                 { get('Textarea with parent label').should == 'textarea-with-parent-label-data' }
      it("finds select boxes")              { get('Select with parent label').should == 'select-with-parent-label-data' }
      it("does not find submit buttons")    { get('Input submit with parent label').should be_nil }
      it("does not find image buttons")     { get('Input image with parent label').should be_nil }
      it("does not find hidden fields")     { get('Input hidden with parent label').should be_nil }
    end

    context "with :with option" do
      it("finds inputs that match option")          { get('input-with-id', :with => 'correct-value').should == 'input-with-id-data' }
      it("omits inputs that don't match option")    { get('input-with-id', :with => 'wrong-value').should be_nil }
      it("finds textareas that match option")       { get('textarea-with-id', :with => 'Correct value').should == 'textarea-with-id-data' }
      it("omits textareas that don't match option") { get('textarea-with-id', :with => 'Wrong value').should be_nil }
    end

    context "with :checked option" do
      context "when true" do
        it("finds checked fields")   {}
        it("omits unchecked fields") {}
      end
      context "when false" do
        it("finds unchecked fields") {}
        it("omits checked fields")   {}
      end
      context "when ommitted" do
        it("finds unchecked fields") {}
        it("finds checked fields")   {}
      end
    end
  end

  describe '#fillable_field' do
    subject{ :fillable_field }
    context "by parent label" do
      it("finds inputs with text type")                    { get('Label text').should == 'id-text' }
      it("finds inputs where label has problem chars")     { get("Label text's got an apostrophe").should == 'id-problem-text' }
    end

  end

  describe '#select' do

  end

  describe '#checkbox' do

  end

  describe '#radio_button' do

  end

  describe '#file_field' do

  end

  describe '#option' do

  end

  describe "#optgroup" do
    subject { :optgroup }

    it("finds optgroups by label") { get('Group A').should == 'optgroup-a' }
  end

  describe "#table" do
    subject {:table}

    it("finds cell content regardless of whitespace") {get('whitespaced-table', :rows => [["I have nested whitespace", "I don't"]]).should == 'table-with-whitespace'}
  end
end
