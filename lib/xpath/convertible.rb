module XPath
  module Convertible
    def to_s
      to_xpath
    end

    def to_xpaths
      [to_xpath]
    end

    def to_xpath
      Renderer.render(self)
    end
  end
end
