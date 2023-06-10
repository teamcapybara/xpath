# frozen_string_literal: true

require 'spec_helper'

describe XPath::Union do
  let(:template) { File.read(File.expand_path('fixtures/simple.html', File.dirname(__FILE__))) }
  let(:doc) { Nokogiri::HTML(template) }

  describe '#expressions' do
    it 'should return the expressions' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = XPath::Union.new(@expr1, @expr2)
      expect(@collection.expressions).to eq [@expr1, @expr2]
    end
  end

  describe '#each' do
    it 'should iterate through the expressions' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = XPath::Union.new(@expr1, @expr2)
      exprs = []
      @collection.each { |expr| exprs << expr }
      expect(exprs).to eq [@expr1, @expr2]
    end
  end

  describe '#map' do
    it 'should map the expressions' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = XPath::Union.new(@expr1, @expr2)
      expect(@collection.map(&:expression)).to eq %i[descendant descendant]
    end
  end

  describe '#to_xpath' do
    it 'should create a valid xpath expression' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div).where(x.attr(:id) == 'foo') }
      @collection = XPath::Union.new(@expr1, @expr2)
      @results = doc.xpath(@collection.to_xpath)
      expect(@results[0][:title]).to eq 'fooDiv'
      expect(@results[1].text).to eq 'Blah'
      expect(@results[2].text).to eq 'Bax'
    end
  end

  describe '#where and others' do
    it 'should be delegated to the individual expressions' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = XPath::Union.new(@expr1, @expr2)
      @xpath1 = @collection.where(XPath.attr(:id) == 'foo').to_xpath
      @xpath2 = @collection.where(XPath.attr(:id) == 'fooDiv').to_xpath
      @results = doc.xpath(@xpath1)
      expect(@results[0][:title]).to eq 'fooDiv'
      @results = doc.xpath(@xpath2)
      expect(@results[0][:id]).to eq 'fooDiv'
    end
  end
end
