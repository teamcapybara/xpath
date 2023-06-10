# frozen_string_literal: true

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

  def xpath(type = nil, &block)
    doc.xpath XPath.generate(&block).to_xpath(type)
  end

  it 'should work as a mixin' do
    xpath = Thingy.new.foo_div.to_xpath
    expect(doc.xpath(xpath).first[:title]).to eq 'fooDiv'
  end

  describe '#descendant' do
    it 'should find nodes that are nested below the current node' do
      @results = xpath { |x| x.descendant(:p) }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[1].text).to eq 'Bax'
    end

    it 'should not find nodes outside the context' do
      @results = xpath do |x|
        foo_div = x.descendant(:div).where(x.attr(:id) == 'foo')
        x.descendant(:p).where(x.attr(:id) == foo_div.attr(:title))
      end
      expect(@results[0]).to be_nil
    end

    it 'should find multiple kinds of nodes' do
      @results = xpath { |x| x.descendant(:p, :ul) }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[3].text).to eq 'A list'
    end

    it 'should find all nodes when no arguments given' do
      @results = xpath { |x| x.descendant[x.attr(:id) == 'foo'].descendant }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[4].text).to eq 'A list'
    end
  end

  describe '#child' do
    it 'should find nodes that are nested directly below the current node' do
      @results = xpath { |x| x.descendant(:div).child(:p) }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[1].text).to eq 'Bax'
    end

    it 'should not find nodes that are nested further down below the current node' do
      @results = xpath { |x| x.child(:p) }
      expect(@results[0]).to be_nil
    end

    it 'should find multiple kinds of nodes' do
      @results = xpath { |x| x.descendant(:div).child(:p, :ul) }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[3].text).to eq 'A list'
    end

    it 'should find all nodes when no arguments given' do
      @results = xpath { |x| x.descendant[x.attr(:id) == 'foo'].child }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[3].text).to eq 'A list'
    end
  end

  describe '#axis' do
    it 'should find nodes given the xpath axis' do
      @results = xpath { |x| x.axis(:descendant, :p) }
      expect(@results[0].text).to eq 'Blah'
    end

    it 'should find nodes given the xpath axis without a specific tag' do
      @results = xpath { |x| x.descendant(:div)[x.attr(:id) == 'foo'].axis(:descendant) }
      expect(@results[0][:id]).to eq 'fooDiv'
    end
  end

  describe '#next_sibling' do
    it 'should find nodes which are immediate siblings of the current node' do
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'fooDiv'].next_sibling(:p) }.first.text).to eq 'Bax'
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'fooDiv'].next_sibling(:ul, :p) }.first.text).to eq 'Bax'
      expect(xpath { |x| x.descendant(:p)[x.attr(:title) == 'monkey'].next_sibling(:ul, :p) }.first.text).to eq 'A list'
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'fooDiv'].next_sibling(:ul, :li) }.first).to be_nil
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'fooDiv'].next_sibling }.first.text).to eq 'Bax'
    end
  end

  describe '#previous_sibling' do
    it 'should find nodes which are exactly preceding the current node' do
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'wooDiv'].previous_sibling(:p) }.first.text).to eq 'Bax'
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'wooDiv'].previous_sibling(:ul, :p) }.first.text).to eq 'Bax'
      expect(xpath { |x| x.descendant(:p)[x.attr(:title) == 'gorilla'].previous_sibling(:ul, :p) }.first.text).to eq 'A list'
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'wooDiv'].previous_sibling(:ul, :li) }.first).to be_nil
      expect(xpath { |x| x.descendant(:p)[x.attr(:id) == 'wooDiv'].previous_sibling }.first.text).to eq 'Bax'
    end
  end

  describe '#anywhere' do
    it 'should find nodes regardless of the context' do
      @results = xpath do |x|
        foo_div = x.anywhere(:div).where(x.attr(:id) == 'foo')
        x.descendant(:p).where(x.attr(:id) == foo_div.attr(:title))
      end
      expect(@results[0].text).to eq 'Blah'
    end

    it 'should find multiple kinds of nodes regardless of the context' do
      @results = xpath do |x|
        context = x.descendant(:div).where(x.attr(:id) == 'woo')
        context.anywhere(:p, :ul)
      end

      expect(@results[0].text).to eq 'Blah'
      expect(@results[3].text).to eq 'A list'
      expect(@results[4].text).to eq 'A list'
      expect(@results[6].text).to eq 'Bax'
    end

    it 'should find all nodes when no arguments given regardless of the context' do
      @results = xpath do |x|
        context = x.descendant(:div).where(x.attr(:id) == 'woo')
        context.anywhere
      end
      expect(@results[0].name).to eq 'html'
      expect(@results[1].name).to eq 'head'
      expect(@results[2].name).to eq 'body'
      expect(@results[6].text).to eq 'Blah'
      expect(@results[10].text).to eq 'A list'
      expect(@results[13].text).to eq 'A list'
      expect(@results[15].text).to eq 'Bax'
    end
  end

  describe '#contains' do
    it 'should find nodes that contain the given string' do
      @results = xpath do |x|
        x.descendant(:div).where(x.attr(:title).contains('ooD'))
      end
      expect(@results[0][:id]).to eq 'foo'
    end

    it 'should find nodes that contain the given expression' do
      @results = xpath do |x|
        expression = x.anywhere(:div).where(x.attr(:title) == 'fooDiv').attr(:id)
        x.descendant(:div).where(x.attr(:title).contains(expression))
      end
      expect(@results[0][:id]).to eq 'foo'
    end
  end

  describe '#contains_word' do
    it 'should find nodes that contain the given word in its entirety' do
      @results = xpath do |x|
        x.descendant.where(x.attr(:class).contains_word('fish'))
      end
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1].text).to eq 'llama'
      expect(@results.length).to eq 2
    end
  end

  describe '#starts_with' do
    it 'should find nodes that begin with the given string' do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).starts_with('foo'))
      end
      expect(@results.size).to eq 2
      expect(@results[0][:id]).to eq 'foo'
      expect(@results[1][:id]).to eq 'fooDiv'
    end

    it 'should find nodes that contain the given expression' do
      @results = xpath do |x|
        expression = x.anywhere(:div).where(x.attr(:title) == 'fooDiv').attr(:id)
        x.descendant(:div).where(x.attr(:title).starts_with(expression))
      end
      expect(@results[0][:id]).to eq 'foo'
    end
  end

  describe '#ends_with' do
    it 'should find nodes that end with the given string' do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).ends_with('oof'))
      end
      expect(@results.size).to eq 2
      expect(@results[0][:id]).to eq 'oof'
      expect(@results[1][:id]).to eq 'viDoof'
    end

    it 'should find nodes that contain the given expression' do
      @results = xpath do |x|
        expression = x.anywhere(:div).where(x.attr(:title) == 'viDoof').attr(:id)
        x.descendant(:div).where(x.attr(:title).ends_with(expression))
      end
      expect(@results[0][:id]).to eq 'oof'
    end
  end

  describe '#uppercase' do
    it 'should match uppercased text' do
      @results = xpath do |x|
        x.descendant(:div).where(x.attr(:title).uppercase == 'VIDOOF')
      end
      expect(@results[0][:id]).to eq 'oof'
    end
  end

  describe '#lowercase' do
    it 'should match lowercased text' do
      @results = xpath do |x|
        x.descendant(:div).where(x.attr(:title).lowercase == 'vidoof')
      end
      expect(@results[0][:id]).to eq 'oof'
    end
  end

  describe '#text' do
    it "should select a node's text" do
      @results = xpath { |x| x.descendant(:p).where(x.text == 'Bax') }
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1][:title]).to eq 'monkey'
      @results = xpath { |x| x.descendant(:div).where(x.descendant(:p).text == 'Bax') }
      expect(@results[0][:title]).to eq 'fooDiv'
    end
  end

  describe '#substring' do
    context 'when called with one argument' do
      it 'should select the part of a string after the specified character' do
        @results = xpath { |x| x.descendant(:span).where(x.attr(:id) == 'substring').text.substring(7) }
        expect(@results).to eq 'there'
      end
    end

    context 'when called with two arguments' do
      it 'should select the part of a string after the specified character, up to the given length' do
        @results = xpath { |x| x.descendant(:span).where(x.attr(:id) == 'substring').text.substring(2, 4) }
        expect(@results).to eq 'ello'
      end
    end
  end

  describe '#function' do
    it 'should call the given xpath function' do
      @results = xpath { |x| x.function(:boolean, x.function(:true) == x.function(:false)) }
      expect(@results).to be false
    end
  end

  describe '#method' do
    it 'should call the given xpath function with the current node as the first argument' do
      @results = xpath { |x| x.descendant(:span).where(x.attr(:id) == 'string-length').text.method(:"string-length") }
      expect(@results).to eq 11
    end
  end

  describe '#string_length' do
    it 'should return the length of a string' do
      @results = xpath { |x| x.descendant(:span).where(x.attr(:id) == 'string-length').text.string_length }
      expect(@results).to eq 11
    end
  end

  describe '#where' do
    it 'should limit the expression to find only certain nodes' do
      expect(xpath { |x| x.descendant(:div).where(:"@id = 'foo'") }.first[:title]).to eq 'fooDiv'
    end

    it 'should be aliased as []' do
      expect(xpath { |x| x.descendant(:div)[:"@id = 'foo'"] }.first[:title]).to eq 'fooDiv'
    end

    it 'should be a no-op when nil condition is passed' do
      expect(XPath.descendant(:div).where(nil).to_s).to eq './/div'
    end
  end

  describe '#inverse' do
    it 'should invert the expression' do
      expect(xpath { |x| x.descendant(:p).where(x.attr(:id).equals('fooDiv').inverse) }.first.text).to eq 'Bax'
    end

    it 'should be aliased as the unary tilde' do
      expect(xpath { |x| x.descendant(:p).where(~x.attr(:id).equals('fooDiv')) }.first.text).to eq 'Bax'
    end

    it 'should be aliased as the unary bang' do
      expect(xpath { |x| x.descendant(:p).where(!x.attr(:id).equals('fooDiv')) }.first.text).to eq 'Bax'
    end
  end

  describe '#equals' do
    it 'should limit the expression to find only certain nodes' do
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id).equals('foo')) }.first[:title]).to eq 'fooDiv'
    end

    it 'should be aliased as ==' do
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id) == 'foo') }.first[:title]).to eq 'fooDiv'
    end
  end

  describe '#not_equals' do
    it 'should match only when not equal' do
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id).not_equals('bar')) }.first[:title]).to eq 'fooDiv'
    end

    it 'should be aliased as !=' do
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id) != 'bar') }.first[:title]).to eq 'fooDiv'
    end
  end

  describe '#is' do
    it 'uses equality when :exact given' do
      expect(xpath(:exact) { |x| x.descendant(:div).where(x.attr(:id).is('foo')) }.first[:title]).to eq 'fooDiv'
      expect(xpath(:exact) { |x| x.descendant(:div).where(x.attr(:id).is('oo')) }.first).to be_nil
    end

    it 'uses substring matching otherwise' do
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id).is('foo')) }.first[:title]).to eq 'fooDiv'
      expect(xpath { |x| x.descendant(:div).where(x.attr(:id).is('oo')) }.first[:title]).to eq 'fooDiv'
    end
  end

  describe '#one_of' do
    it 'should return all nodes where the condition matches' do
      @results = xpath do |x|
        p = x.anywhere(:div).where(x.attr(:id) == 'foo').attr(:title)
        x.descendant(:*).where(x.attr(:id).one_of('foo', p, 'baz'))
      end
      expect(@results[0][:title]).to eq 'fooDiv'
      expect(@results[1].text).to eq 'Blah'
      expect(@results[2][:title]).to eq 'bazDiv'
    end
  end

  describe '#and' do
    it 'should find all nodes in both expression' do
      @results = xpath do |x|
        x.descendant(:*).where(x.contains('Bax').and(x.attr(:title).equals('monkey')))
      end
      expect(@results[0][:title]).to eq 'monkey'
    end

    it 'should be aliased as ampersand (&)' do
      @results = xpath do |x|
        x.descendant(:*).where(x.contains('Bax') & x.attr(:title).equals('monkey'))
      end
      expect(@results[0][:title]).to eq 'monkey'
    end
  end

  describe '#or' do
    it 'should find all nodes in either expression' do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).equals('foo').or(x.attr(:id).equals('fooDiv')))
      end
      expect(@results[0][:title]).to eq 'fooDiv'
      expect(@results[1].text).to eq 'Blah'
    end

    it 'should be aliased as pipe (|)' do
      @results = xpath do |x|
        x.descendant(:*).where(x.attr(:id).equals('foo') | x.attr(:id).equals('fooDiv'))
      end
      expect(@results[0][:title]).to eq 'fooDiv'
      expect(@results[1].text).to eq 'Blah'
    end
  end

  describe '#attr' do
    it 'should be an attribute' do
      @results = xpath { |x| x.descendant(:div).where(x.attr(:id)) }
      expect(@results[0][:title]).to eq 'barDiv'
      expect(@results[1][:title]).to eq 'fooDiv'
    end
  end

  describe '#css' do
    it 'should find nodes by the given CSS selector' do
      @results = xpath { |x| x.css('#preference p') }
      expect(@results[0].text).to eq 'allamas'
      expect(@results[1].text).to eq 'llama'
    end

    it 'should respect previous expression' do
      @results = xpath { |x| x.descendant[x.attr(:id) == 'moar'].css('p') }
      expect(@results[0].text).to eq 'chimp'
      expect(@results[1].text).to eq 'flamingo'
    end

    it 'should be composable' do
      @results = xpath { |x| x.css('#moar').descendant(:p) }
      expect(@results[0].text).to eq 'chimp'
      expect(@results[1].text).to eq 'flamingo'
    end

    it 'should allow comma separated selectors' do
      @results = xpath { |x| x.descendant[x.attr(:id) == 'moar'].css('div, p') }
      expect(@results[0].text).to eq 'chimp'
      expect(@results[1].text).to eq 'elephant'
      expect(@results[2].text).to eq 'flamingo'
    end
  end

  describe '#qname' do
    it "should match the node's name" do
      expect(xpath { |x| x.descendant(:*).where(x.qname == 'ul') }.first.text).to eq 'A list'
    end
  end

  describe '#union' do
    it 'should create a union expression' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = @expr1.union(@expr2)
      @xpath1 = @collection.where(XPath.attr(:id) == 'foo').to_xpath
      @xpath2 = @collection.where(XPath.attr(:id) == 'fooDiv').to_xpath
      @results = doc.xpath(@xpath1)
      expect(@results[0][:title]).to eq 'fooDiv'
      @results = doc.xpath(@xpath2)
      expect(@results[0][:id]).to eq 'fooDiv'
    end

    it 'should be aliased as +' do
      @expr1 = XPath.generate { |x| x.descendant(:p) }
      @expr2 = XPath.generate { |x| x.descendant(:div) }
      @collection = @expr1 + @expr2
      @xpath1 = @collection.where(XPath.attr(:id) == 'foo').to_xpath
      @xpath2 = @collection.where(XPath.attr(:id) == 'fooDiv').to_xpath
      @results = doc.xpath(@xpath1)
      expect(@results[0][:title]).to eq 'fooDiv'
      @results = doc.xpath(@xpath2)
      expect(@results[0][:id]).to eq 'fooDiv'
    end
  end

  describe '#last' do
    it 'returns the number of elements in the context' do
      @results = xpath { |x| x.descendant(:p)[XPath.position == XPath.last] }
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1].text).to eq 'Blah'
      expect(@results[2].text).to eq 'llama'
    end
  end

  describe '#position' do
    it 'returns the position of elements in the context' do
      @results = xpath { |x| x.descendant(:p)[XPath.position == 2] }
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1].text).to eq 'Bax'
    end
  end

  describe '#count' do
    it 'counts the number of occurrences' do
      @results = xpath { |x| x.descendant(:div)[x.descendant(:p).count == 2] }
      expect(@results[0][:id]).to eq 'preference'
    end
  end

  describe '#lte' do
    it 'checks lesser than or equal' do
      @results = xpath { |x| x.descendant(:p)[XPath.position <= 2] }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[1].text).to eq 'Bax'
      expect(@results[2][:title]).to eq 'gorilla'
      expect(@results[3].text).to eq 'Bax'
    end
  end

  describe '#lt' do
    it 'checks lesser than' do
      @results = xpath { |x| x.descendant(:p)[XPath.position < 2] }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[1][:title]).to eq 'gorilla'
    end
  end

  describe '#gte' do
    it 'checks greater than or equal' do
      @results = xpath { |x| x.descendant(:p)[XPath.position >= 2] }
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1][:title]).to eq 'monkey'
      expect(@results[2].text).to eq 'Bax'
      expect(@results[3].text).to eq 'Blah'
    end
  end

  describe '#gt' do
    it 'checks greater than' do
      @results = xpath { |x| x.descendant(:p)[XPath.position > 2] }
      expect(@results[0][:title]).to eq 'monkey'
      expect(@results[1].text).to eq 'Blah'
    end
  end

  describe '#plus' do
    it 'adds stuff' do
      @results = xpath { |x| x.descendant(:p)[XPath.position.plus(1) == 2] }
      expect(@results[0][:id]).to eq 'fooDiv'
      expect(@results[1][:title]).to eq 'gorilla'
    end
  end

  describe '#minus' do
    it 'subtracts stuff' do
      @results = xpath { |x| x.descendant(:p)[XPath.position.minus(1) == 0] }
      expect(@results[0][:id]).to eq 'fooDiv'
      expect(@results[1][:title]).to eq 'gorilla'
    end
  end

  describe '#multiply' do
    it 'multiplies stuff' do
      @results = xpath { |x| x.descendant(:p)[XPath.position * 3 == 3] }
      expect(@results[0][:id]).to eq 'fooDiv'
      expect(@results[1][:title]).to eq 'gorilla'
    end
  end

  describe '#divide' do
    it 'divides stuff' do
      @results = xpath { |x| x.descendant(:p)[XPath.position / 2 == 1] }
      expect(@results[0].text).to eq 'Bax'
      expect(@results[1].text).to eq 'Bax'
    end
  end

  describe '#mod' do
    it 'take modulo' do
      @results = xpath { |x| x.descendant(:p)[XPath.position % 2 == 1] }
      expect(@results[0].text).to eq 'Blah'
      expect(@results[1][:title]).to eq 'monkey'
      expect(@results[2][:title]).to eq 'gorilla'
    end
  end

  describe '#ancestor' do
    it 'finds ancestor nodes' do
      @results = xpath { |x| x.descendant(:p)[1].ancestor }
      expect(@results[0].node_name).to eq 'html'
      expect(@results[1].node_name).to eq 'body'
      expect(@results[2][:id]).to eq 'foo'
    end
  end
end
