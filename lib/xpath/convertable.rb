module XPath
  module Convertable
    def to_s
      to_xpaths.join(' | ')
    end

    def to_xpaths
      [to_xpath(:exact), to_xpath(:fuzzy)].uniq
    end

    def to_xpath(predicate=nil)
      Renderer.render(predicate, self)
    end
  end
end
