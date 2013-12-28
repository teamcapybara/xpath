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
    type = example.metadata[:type]
    doc.xpath(XPath::HTML.send(subject, *args).to_xpath(type)).map { |node| node[:data] }
  end

  describe '#link' do
    subject { :link }

    it("finds links by id")                                { expect(get('some-id')).to eq('link-id') }
    it("finds links by content")                           { expect(get('An awesome link')).to eq('link-text') }
    it("finds links by content regardless of whitespace")  { expect(get('My whitespaced link')).to eq('link-whitespace') }
    it("finds links with child tags by content")           { expect(get('An emphatic link')).to eq('link-children') }
    it("finds links by the content of their child tags")   { expect(get('emphatic')).to eq('link-children') }
    it("finds links by approximate content")               { expect(get('awesome')).to eq('link-text') }
    it("finds links by title")                             { expect(get('My title')).to eq('link-title') }
    it("finds links by approximate title")                 { expect(get('title')).to eq('link-title') }
    it("finds links by image's alt attribute")             { expect(get('Alt link')).to eq('link-img') }
    it("finds links by image's approximate alt attribute") { expect(get('Alt')).to eq('link-img') }
    it("does not find links without href attriutes")       { expect(get('Wrong Link')).to be_nil }
    it("casts to string")                                  { expect(get(:'some-id')).to eq('link-id') }

    context "with exact match", :type => :exact do
      it("finds links by content")                                   { expect(get('An awesome link')).to eq('link-text') }
      it("does not find links by approximate content")               { expect(get('awesome')).to be_nil }
      it("finds links by title")                                     { expect(get('My title')).to eq('link-title') }
      it("does not find links by approximate title")                 { expect(get('title')).to be_nil }
      it("finds links by image's alt attribute")                     { expect(get('Alt link')).to eq('link-img') }
      it("does not find links by image's approximate alt attribute") { expect(get('Alt')).to be_nil }
    end
  end

  describe '#button' do
    subject { :button }

    context "with submit type" do
      it("finds buttons by id")                { expect(get('submit-with-id')).to eq('id-submit') }
      it("finds buttons by value")             { expect(get('submit-with-value')).to eq('value-submit') }
      it("finds buttons by approximate value") { expect(get('mit-with-val')).to eq('value-submit') }
      it("finds buttons by title")             { expect(get('My submit title')).to eq('title-submit') }
      it("finds buttons by approximate title") { expect(get('submit title')).to eq('title-submit') }

      context "with exact match", :type => :exact do
        it("finds buttons by value")                     { expect(get('submit-with-value')).to eq('value-submit') }
        it("does not find buttons by approximate value") { expect(get('mit-with-val')).to be_nil }
        it("finds buttons by title")                     { expect(get('My submit title')).to eq('title-submit') }
        it("does not find buttons by approximate title") { expect(get('submit title')).to be_nil }
      end
    end

    context "with reset type" do
      it("finds buttons by id")                { expect(get('reset-with-id')).to eq('id-reset') }
      it("finds buttons by value")             { expect(get('reset-with-value')).to eq('value-reset') }
      it("finds buttons by approximate value") { expect(get('set-with-val')).to eq('value-reset') }
      it("finds buttons by title")             { expect(get('My reset title')).to eq('title-reset') }
      it("finds buttons by approximate title") { expect(get('reset title')).to eq('title-reset') }

      context "with exact match", :type => :exact do
        it("finds buttons by value")                     { expect(get('reset-with-value')).to eq('value-reset') }
        it("does not find buttons by approximate value") { expect(get('set-with-val')).to be_nil }
        it("finds buttons by title")                     { expect(get('My reset title')).to eq('title-reset') }
        it("does not find buttons by approximate title") { expect(get('reset title')).to be_nil }
      end
    end

    context "with button type" do
      it("finds buttons by id")                { expect(get('button-with-id')).to eq('id-button') }
      it("finds buttons by value")             { expect(get('button-with-value')).to eq('value-button') }
      it("finds buttons by approximate value") { expect(get('ton-with-val')).to eq('value-button') }
      it("finds buttons by title")             { expect(get('My button title')).to eq('title-button') }
      it("finds buttons by approximate title") { expect(get('button title')).to eq('title-button') }

      context "with exact match", :type => :exact do
        it("finds buttons by value")                     { expect(get('button-with-value')).to eq('value-button') }
        it("does not find buttons by approximate value") { expect(get('ton-with-val')).to be_nil }
        it("finds buttons by title")                     { expect(get('My button title')).to eq('title-button') }
        it("does not find buttons by approximate title") { expect(get('button title')).to be_nil }
      end
    end

    context "with image type" do
      it("finds buttons by id")                        { expect(get('imgbut-with-id')).to eq('id-imgbut') }
      it("finds buttons by value")                     { expect(get('imgbut-with-value')).to eq('value-imgbut') }
      it("finds buttons by approximate value")         { expect(get('gbut-with-val')).to eq('value-imgbut') }
      it("finds buttons by alt attribute")             { expect(get('imgbut-with-alt')).to eq('alt-imgbut') }
      it("finds buttons by approximate alt attribute") { expect(get('mgbut-with-al')).to eq('alt-imgbut') }
      it("finds buttons by title")                     { expect(get('My imgbut title')).to eq('title-imgbut') }
      it("finds buttons by approximate title")         { expect(get('imgbut title')).to eq('title-imgbut') }

      context "with exact match", :type => :exact do
        it("finds buttons by value")                             { expect(get('imgbut-with-value')).to eq('value-imgbut') }
        it("does not find buttons by approximate value")         { expect(get('gbut-with-val')).to be_nil }
        it("finds buttons by alt attribute")                     { expect(get('imgbut-with-alt')).to eq('alt-imgbut') }
        it("does not find buttons by approximate alt attribute") { expect(get('mgbut-with-al')).to be_nil }
        it("finds buttons by title")                             { expect(get('My imgbut title')).to eq('title-imgbut') }
        it("does not find buttons by approximate title")         { expect(get('imgbut title')).to be_nil }
      end
    end

    context "with button tag" do
      it("finds buttons by id")                       { expect(get('btag-with-id')).to eq('id-btag') }
      it("finds buttons by value")                    { expect(get('btag-with-value')).to eq('value-btag') }
      it("finds buttons by approximate value")        { expect(get('tag-with-val')).to eq('value-btag') }
      it("finds buttons by text")                     { expect(get('btag-with-text')).to eq('text-btag') }
      it("finds buttons by text ignoring whitespace") { expect(get('My whitespaced button')).to eq('btag-with-whitespace') }
      it("finds buttons by approximate text ")        { expect(get('tag-with-tex')).to eq('text-btag') }
      it("finds buttons with child tags by text")     { expect(get('An emphatic button')).to eq('btag-with-children') }
      it("finds buttons by text of their children")   { expect(get('emphatic')).to eq('btag-with-children') }
      it("finds buttons by title")                    { expect(get('My btag title')).to eq('title-btag') }
      it("finds buttons by approximate title")        { expect(get('btag title')).to eq('title-btag') }

      context "with exact match", :type => :exact do
        it("finds buttons by value")                     { expect(get('btag-with-value')).to eq('value-btag') }
        it("does not find buttons by approximate value") { expect(get('tag-with-val')).to be_nil }
        it("finds buttons by text")                      { expect(get('btag-with-text')).to eq('text-btag') }
        it("does not find buttons by approximate text ") { expect(get('tag-with-tex')).to be_nil }
        it("finds buttons by title")                     { expect(get('My btag title')).to eq('title-btag') }
        it("does not find buttons by approximate title") { expect(get('btag title')).to be_nil }
      end
    end

    context "with unkown type" do
      it("does not find the button") { expect(get('schmoo button')).to be_nil }
    end

    it("casts to string") { expect(get(:'tag-with-tex')).to eq('text-btag') }
  end

  describe '#fieldset' do
    subject { :fieldset }

    it("finds fieldsets by id")                  { expect(get('some-fieldset-id')).to eq('fieldset-id') }
    it("finds fieldsets by legend")              { expect(get('Some Legend')).to eq('fieldset-legend') }
    it("finds fieldsets by legend child tags")   { expect(get('Span Legend')).to eq('fieldset-legend-span') }
    it("accepts approximate legends")            { expect(get('Legend')).to eq('fieldset-legend') }
    it("finds nested fieldsets by legend")       { expect(get('Inner legend')).to eq('fieldset-inner') }
    it("casts to string")                        { expect(get(:'Inner legend')).to eq('fieldset-inner') }

    context "with exact match", :type => :exact do
      it("finds fieldsets by legend")            { expect(get('Some Legend')).to eq('fieldset-legend') }
      it("does not find by approximate legends") { expect(get('Legend')).to be_nil }
    end
  end

  describe '#field' do
    subject { :field }

    context "by id" do
      it("finds inputs with no type")       { expect(get('input-with-id')).to eq('input-with-id-data') }
      it("finds inputs with text type")     { expect(get('input-text-with-id')).to eq('input-text-with-id-data') }
      it("finds inputs with password type") { expect(get('input-password-with-id')).to eq('input-password-with-id-data') }
      it("finds inputs with custom type")   { expect(get('input-custom-with-id')).to eq('input-custom-with-id-data') }
      it("finds textareas")                 { expect(get('textarea-with-id')).to eq('textarea-with-id-data') }
      it("finds select boxes")              { expect(get('select-with-id')).to eq('select-with-id-data') }
      it("does not find submit buttons")    { expect(get('input-submit-with-id')).to be_nil }
      it("does not find image buttons")     { expect(get('input-image-with-id')).to be_nil }
      it("does not find hidden fields")     { expect(get('input-hidden-with-id')).to be_nil }
    end

    context "by name" do
      it("finds inputs with no type")       { expect(get('input-with-name')).to eq('input-with-name-data') }
      it("finds inputs with text type")     { expect(get('input-text-with-name')).to eq('input-text-with-name-data') }
      it("finds inputs with password type") { expect(get('input-password-with-name')).to eq('input-password-with-name-data') }
      it("finds inputs with custom type")   { expect(get('input-custom-with-name')).to eq('input-custom-with-name-data') }
      it("finds textareas")                 { expect(get('textarea-with-name')).to eq('textarea-with-name-data') }
      it("finds select boxes")              { expect(get('select-with-name')).to eq('select-with-name-data') }
      it("does not find submit buttons")    { expect(get('input-submit-with-name')).to be_nil }
      it("does not find image buttons")     { expect(get('input-image-with-name')).to be_nil }
      it("does not find hidden fields")     { expect(get('input-hidden-with-name')).to be_nil }
    end

    context "by placeholder" do
      it("finds inputs with no type")       { expect(get('input-with-placeholder')).to eq('input-with-placeholder-data') }
      it("finds inputs with text type")     { expect(get('input-text-with-placeholder')).to eq('input-text-with-placeholder-data') }
      it("finds inputs with password type") { expect(get('input-password-with-placeholder')).to eq('input-password-with-placeholder-data') }
      it("finds inputs with custom type")   { expect(get('input-custom-with-placeholder')).to eq('input-custom-with-placeholder-data') }
      it("finds textareas")                 { expect(get('textarea-with-placeholder')).to eq('textarea-with-placeholder-data') }
      it("does not find hidden fields")     { expect(get('input-hidden-with-placeholder')).to be_nil }
    end

    context "by referenced label" do
      it("finds inputs with no type")       { expect(get('Input with label')).to eq('input-with-label-data') }
      it("finds inputs with text type")     { expect(get('Input text with label')).to eq('input-text-with-label-data') }
      it("finds inputs with password type") { expect(get('Input password with label')).to eq('input-password-with-label-data') }
      it("finds inputs with custom type")   { expect(get('Input custom with label')).to eq('input-custom-with-label-data') }
      it("finds textareas")                 { expect(get('Textarea with label')).to eq('textarea-with-label-data') }
      it("finds select boxes")              { expect(get('Select with label')).to eq('select-with-label-data') }
      it("does not find submit buttons")    { expect(get('Input submit with label')).to be_nil }
      it("does not find image buttons")     { expect(get('Input image with label')).to be_nil }
      it("does not find hidden fields")     { expect(get('Input hidden with label')).to be_nil }
    end

    context "by parent label" do
      it("finds inputs with no type")       { expect(get('Input with parent label')).to eq('input-with-parent-label-data') }
      it("finds inputs with text type")     { expect(get('Input text with parent label')).to eq('input-text-with-parent-label-data') }
      it("finds inputs with password type") { expect(get('Input password with parent label')).to eq('input-password-with-parent-label-data') }
      it("finds inputs with custom type")   { expect(get('Input custom with parent label')).to eq('input-custom-with-parent-label-data') }
      it("finds textareas")                 { expect(get('Textarea with parent label')).to eq('textarea-with-parent-label-data') }
      it("finds select boxes")              { expect(get('Select with parent label')).to eq('select-with-parent-label-data') }
      it("does not find submit buttons")    { expect(get('Input submit with parent label')).to be_nil }
      it("does not find image buttons")     { expect(get('Input image with parent label')).to be_nil }
      it("does not find hidden fields")     { expect(get('Input hidden with parent label')).to be_nil }
    end

    it("casts to string") { expect(get(:'select-with-id')).to eq('select-with-id-data') }
  end

  describe '#fillable_field' do
    subject{ :fillable_field }
    context "by parent label" do
      it("finds inputs with text type")                    { expect(get('Label text')).to eq('id-text') }
      it("finds inputs where label has problem chars")     { expect(get("Label text's got an apostrophe")).to eq('id-problem-text') }
    end

  end

  describe '#select' do
    subject{ :select }
    it("finds selects by id")             { expect(get('select-with-id')).to eq('select-with-id-data') }
    it("finds selects by name")           { expect(get('select-with-name')).to eq('select-with-name-data') }
    it("finds selects by label")          { expect(get('Select with label')).to eq('select-with-label-data') }
    it("finds selects by parent label")   { expect(get('Select with parent label')).to eq('select-with-parent-label-data') }
    it("casts to string")                 { expect(get(:'Select with parent label')).to eq('select-with-parent-label-data') }
  end

  describe '#checkbox' do
    subject{ :checkbox }
    it("finds checkboxes by id")           { expect(get('input-checkbox-with-id')).to eq('input-checkbox-with-id-data') }
    it("finds checkboxes by name")         { expect(get('input-checkbox-with-name')).to eq('input-checkbox-with-name-data') }
    it("finds checkboxes by label")        { expect(get('Input checkbox with label')).to eq('input-checkbox-with-label-data') }
    it("finds checkboxes by parent label") { expect(get('Input checkbox with parent label')).to eq('input-checkbox-with-parent-label-data') }
    it("casts to string")                  { expect(get(:'Input checkbox with parent label')).to eq('input-checkbox-with-parent-label-data') }
  end

  describe '#radio_button' do
    subject{ :radio_button }
    it("finds radio buttons by id")           { expect(get('input-radio-with-id')).to eq('input-radio-with-id-data') }
    it("finds radio buttons by name")         { expect(get('input-radio-with-name')).to eq('input-radio-with-name-data') }
    it("finds radio buttons by label")        { expect(get('Input radio with label')).to eq('input-radio-with-label-data') }
    it("finds radio buttons by parent label") { expect(get('Input radio with parent label')).to eq('input-radio-with-parent-label-data') }
    it("casts to string")                     { expect(get(:'Input radio with parent label')).to eq('input-radio-with-parent-label-data') }
  end

  describe '#file_field' do
    subject{ :file_field }
    it("finds file fields by id")           { expect(get('input-file-with-id')).to eq('input-file-with-id-data') }
    it("finds file fields by name")         { expect(get('input-file-with-name')).to eq('input-file-with-name-data') }
    it("finds file fields by label")        { expect(get('Input file with label')).to eq('input-file-with-label-data') }
    it("finds file fields by parent label") { expect(get('Input file with parent label')).to eq('input-file-with-parent-label-data') }
    it("casts to string")                   { expect(get(:'Input file with parent label')).to eq('input-file-with-parent-label-data') }
  end

  describe "#optgroup" do
    subject { :optgroup }
    it("finds optgroups by label")             { expect(get('Group A')).to eq('optgroup-a') }
    it("finds optgroups by approximate label") { expect(get('oup A')).to eq('optgroup-a') }
    it("casts to string")                      { expect(get(:'Group A')).to eq('optgroup-a') }

    context "with exact match", :type => :exact do
      it("finds by label")                     { expect(get('Group A')).to eq('optgroup-a') }
      it("does not find by approximate label") { expect(get('oup A')).to be_nil }
    end
  end

  describe '#option' do
    subject{ :option }
    it("finds by text")             { expect(get('Option with text')).to eq('option-with-text-data') }
    it("finds by approximate text") { expect(get('Option with')).to eq('option-with-text-data') }
    it("casts to string")           { expect(get(:'Option with text')).to eq('option-with-text-data') }

    context "with exact match", :type => :exact do
      it("finds by text")                     { expect(get('Option with text')).to eq('option-with-text-data') }
      it("does not find by approximate text") { expect(get('Option with')).to be_nil }
    end
  end

  describe "#table" do
    subject {:table}
    it("finds by id")                  { expect(get('table-with-id')).to eq('table-with-id-data') }
    it("finds by caption")             { expect(get('Table with caption')).to eq('table-with-caption-data') }
    it("finds by approximate caption") { expect(get('Table with')).to eq('table-with-caption-data') }
    it("casts to string")              { expect(get(:'Table with caption')).to eq('table-with-caption-data') }

    context "with exact match", :type => :exact do
      it("finds by caption")                     { expect(get('Table with caption')).to eq('table-with-caption-data') }
      it("does not find by approximate caption") { expect(get('Table with')).to be_nil }
    end
  end

  describe "#definition_description" do
    subject {:definition_description}
    let(:template) {'stuff'}
    it("find definition description by id")   { expect(get('latte')).to eq("with-id") }
    it("find definition description by term") { expect(get("Milk")).to eq("with-dt") }
    it("casts to string")                     { expect(get(:"Milk")).to eq("with-dt") }
  end
end
