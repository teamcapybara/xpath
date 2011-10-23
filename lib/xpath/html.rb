module XPath
  module HTML
    include XPath
    extend self

    # Match an `a` link element.
    #
    # @param [String] locator
    #   Text, id, title, or image alt attribute of the link
    # @option options [String] :href
    #   `href` attribute of the link
    #
    def link(locator, options={})
      href = options[:href]
      link = descendant(:a)[href ? attr(:href).equals(href) : attr(:href)]
      link[attr(:id).equals(locator) | string.n.is(locator) | attr(:title).is(locator) | descendant(:img)[attr(:alt).is(locator)]]
    end


    def content(locator)
      child(:"descendant-or-self::*")[current.n.contains(locator)]
    end


    # Match a `submit`, `image`, or `button` element.
    #
    # @param [String] locator
    #   Value, title, id, or image alt attribute of the button
    #
    def button(locator)
      button = descendant(:input)[attr(:type).one_of('submit', 'image', 'button')][attr(:id).equals(locator) | attr(:value).is(locator) | attr(:title).is(locator)]
      button += descendant(:button)[attr(:id).equals(locator) | attr(:value).is(locator) | string.n.is(locator) | attr(:title).is(locator)]
      button += descendant(:input)[attr(:type).equals('image')][attr(:alt).is(locator)]
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
      descendant(:fieldset)[attr(:id).equals(locator) | child(:legend)[string.n.is(locator)]]
    end


    # Match any `input`, `textarea`, or `select` element that doesn't have a
    # type of `submit`, `image`, or `hidden`.
    #
    # @param [String] locator
    #   Label, id, or name of field to match
    # @option options [Bool] :checked
    #   Match only if the input has a `checked` attribute
    # @option options [Bool] :unchecked
    #   Match only if the input does not have a `checked` attribute
    # @option options [String] :with
    #   Text that matches only elements with this value
    #   (`value` attribute or contained text)
    #
    def field(locator, options={})
      xpath = descendant(:input, :textarea, :select)[~attr(:type).one_of('submit', 'image', 'hidden')]
      xpath = locate_field(xpath, locator)
      xpath = xpath[attr(:checked)] if options[:checked]
      xpath = xpath[~attr(:checked)] if options[:unchecked]
      xpath = xpath[field_value(options[:with])] if options.has_key?(:with)
      xpath
    end


    # Match any `input` or `textarea` element that can be filled with text.
    # This excludes any inputs with a type of `submit`, `image`, `radio`,
    # `checkbox`, `hidden`, or `file`.
    #
    # @param [String] locator
    #   Label, id, or name of field to match
    # @option options [String] :with
    #   Text that matches only elements with this value
    #   (`value` attribute or contained text)
    #
    def fillable_field(locator, options={})
      xpath = descendant(:input, :textarea)[~attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
      xpath = locate_field(xpath, locator)
      xpath = xpath[field_value(options[:with])] if options.has_key?(:with)
      xpath
    end


    # Match any `select` element.
    #
    # @param [String] locator
    #   Label, id, or name of the field to match
    # @option options [Array] :options
    # @option options [Array] :selected
    #
    def select(locator, options={})
      xpath = locate_field(descendant(:select), locator)

      options[:options].each do |option|
        xpath = xpath[descendant(:option).equals(option)]
      end if options[:options]

      [options[:selected]].flatten.each do |option|
        xpath = xpath[descendant(:option)[attr(:selected)].equals(option)]
      end if options[:selected]

      xpath
    end


    # Match any `input` element of type `checkbox`.
    #
    # @param [String] locator
    #   Label, id, or name of the checkbox to match
    #
    def checkbox(locator, options={})
      xpath = locate_field(descendant(:input)[attr(:type).equals('checkbox')], locator)
    end


    # Match any `input` element of type `radio`.
    #
    # @param [String] locator
    #   Label, id, or name of the radio button to match
    #
    def radio_button(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('radio')], locator)
    end


    # Match any `input` element of type `file`.
    #
    # @param [String] locator
    #   Label, id, or name of the file field to match
    #
    def file_field(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('file')], locator)
    end


    # Match an `optgroup` element.
    #
    # @param [String] name
    #   Label for the option group
    #
    def optgroup(name)
      descendant(:optgroup)[attr(:label).is(name)]
    end


    # Match an `option` element.
    #
    # @param [String] name
    #   Visible text of the option
    #
    def option(name)
      descendant(:option)[string.n.is(name)]
    end


    # Match any `table` element.
    #
    # @param [String] locator
    #   Caption or id of the table to match
    # @option options [Array] :rows
    #   Content of each cell in each row to match
    #
    def table(locator, options={})
      xpath = descendant(:table)[attr(:id).equals(locator) | descendant(:caption).contains(locator)]
      xpath = xpath[table_rows(options[:rows])] if options[:rows]
      xpath
    end


    # Match content in consecutive table rows.
    #
    # @param [Array] rows
    #   Array of arrays of strings containing cell content to match
    #
    def table_rows(rows)
      row_conditions = descendant(:tr)[table_row(rows.first)]
      rows.drop(1).each do |row|
        row_conditions = row_conditions.next_sibling(:tr)[table_row(row)]
      end
      row_conditions
    end


    # Match content in consecutive table cells.
    #
    # @param [Array] cells
    #   Array of strings to match against consecutive cell contents.
    #
    def table_row(cells)
      cell_conditions = child(:td, :th)[string.n.equals(cells.first)]
      cells.drop(1).each do |cell|
        cell_conditions = cell_conditions.next_sibling(:td, :th)[string.n.equals(cell)]
      end
      cell_conditions
    end

    # Match any 'dd' element.
    #
    # @param [String] locator
    #   Id of the 'dd' element or text from preciding 'dt' element content
    def definition_description(locator)
      descendant(:dd)[attr(:id).equals(locator) | previous_sibling(:dt)[string.n.equals(locator)] ]
    end

  protected

    def locate_field(xpath, locator)
      locate_field = xpath[attr(:id).equals(locator) | attr(:name).equals(locator) | attr(:placeholder).equals(locator) | attr(:id).equals(anywhere(:label)[string.n.is(locator)].attr(:for))]
      locate_field += descendant(:label)[string.n.is(locator)].descendant(xpath)
    end

    def field_value(value)
      (string.n.is(value) & tag(:textarea)) | (attr(:value).equals(value) & ~tag(:textarea))
    end

  end
end
