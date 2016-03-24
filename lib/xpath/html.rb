module XPath
  module HTML
    include XPath::DSL::TopLevel
    extend self

    # Match an `a` link element.
    #
    # @param [String] locator
    #   Text, id, title, or image alt attribute of the link
    #
    def link(locator)
      link = descendant(:a)[attr(:href)]
      unless locator.nil?
        locator = locator.to_s
        link = link[attr(:id).equals(locator) | string.n.is(locator) | attr(:title).is(locator) | descendant(:img)[attr(:alt).is(locator)]]
      end
      link
    end

    # Match a `submit`, `image`, or `button` element.
    #
    # @param [String] locator
    #   Value, title, id, or image alt attribute of the button
    #
    def button(locator)
      input_button = descendant(:input)[attr(:type).one_of('submit', 'reset', 'image', 'button')]
      button = descendant(:button)
      image_button = descendant(:input)[attr(:type).equals('image')]

      unless locator.nil?
        locator = locator.to_s
        input_button = input_button[attr(:id).equals(locator) | attr(:value).is(locator) | attr(:title).is(locator)]
        button = button[attr(:id).equals(locator) | attr(:value).is(locator) | string.n.is(locator) | attr(:title).is(locator)]
        image_button = image_button[attr(:alt).is(locator)]
      end

      input_button + button + image_button
    end


    # Match anything returned by either {#link} or {#button}.
    #
    # @param [String] locator
    #   Text, id, title, or image alt attribute of the link or button
    #
    def link_or_button(locator)
      link(locator) + button(locator)
    end


    # Match any `fieldset` element.
    #
    # @param [String] locator
    #   Legend or id of the fieldset
    #
    def fieldset(locator)
      fieldset = descendant(:fieldset)
      unless locator.nil?
        locator = locator.to_s
        fieldset = fieldset[attr(:id).equals(locator) | child(:legend)[string.n.is(locator)]]
      end
      fieldset
    end


    # Match any `input`, `textarea`, or `select` element that doesn't have a
    # type of `submit`, `image`, or `hidden`.
    #
    # @param [String] locator
    #   Label, id, or name of field to match
    #
    def field(locator)
      xpath = descendant(:input, :textarea, :select)[~attr(:type).one_of('submit', 'image', 'hidden')]
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match any `input` or `textarea` element that can be filled with text.
    # This excludes any inputs with a type of `submit`, `image`, `radio`,
    # `checkbox`, `hidden`, or `file`.
    #
    # @param [String] locator
    #   Label, id, or name of field to match
    #
    def fillable_field(locator)
      xpath = descendant(:input, :textarea)[~attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match any `select` element.
    #
    # @param [String] locator
    #   Label, id, or name of the field to match
    #
    def select(locator)
      xpath = descendant(:select)
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match any `input` element of type `checkbox`.
    #
    # @param [String] locator
    #   Label, id, or name of the checkbox to match
    #
    def checkbox(locator)
      xpath = descendant(:input)[attr(:type).equals('checkbox')]
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match any `input` element of type `radio`.
    #
    # @param [String] locator
    #   Label, id, or name of the radio button to match
    #
    def radio_button(locator)
      xpath = descendant(:input)[attr(:type).equals('radio')]
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match any `input` element of type `file`.
    #
    # @param [String] locator
    #   Label, id, or name of the file field to match
    #
    def file_field(locator)
      xpath = descendant(:input)[attr(:type).equals('file')]
      xpath = locate_field(xpath, locator.to_s) unless locator.nil?
      xpath
    end


    # Match an `optgroup` element.
    #
    # @param [String] name
    #   Label for the option group
    #
    def optgroup(locator)
      xpath = descendant(:optgroup)
      xpath = xpath[attr(:label).is(locator.to_s)] unless locator.nil?
      xpath
    end


    # Match an `option` element.
    #
    # @param [String] name
    #   Visible text of the option
    #
    def option(locator)
      xpath = descendant(:option)
      xpath = xpath[string.n.is(locator.to_s)] unless locator.nil?
      xpath
    end


    # Match any `table` element.
    #
    # @param [String] locator
    #   Caption or id of the table to match
    # @option options [Array] :rows
    #   Content of each cell in each row to match
    #
    def table(locator)
      xpath = descendant(:table)
      xpath = xpath[attr(:id).equals(locator.to_s) | descendant(:caption).is(locator.to_s)] unless locator.nil?
      xpath
    end

    # Match any 'dd' element.
    #
    # @param [String] locator
    #   Id of the 'dd' element or text from preciding 'dt' element content
    def definition_description(locator)
      xpath = descendant(:dd)
      xpath = xpath[attr(:id).equals(locator.to_s) | previous_sibling(:dt)[string.n.equals(locator.to_s)] ] unless locator.nil?
      xpath
    end

  protected

    def locate_field(xpath, locator)
      locate_field = xpath[attr(:id).equals(locator) | attr(:name).equals(locator) | attr(:placeholder).equals(locator) | attr(:id).equals(anywhere(:label)[string.n.is(locator)].attr(:for))]
      locate_field += descendant(:label)[string.n.is(locator)].descendant(xpath)
      locate_field
    end
  end
end
