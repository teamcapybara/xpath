module XPath
  module HTML
    include XPath
    extend self

    def link(locator, options={})
      href = options[:href]
      link = descendant(:a)[href ? attr(:href).equals(href) : attr(:href)]
      link[attr(:id).equals(locator) | string.n.is(locator) | attr(:title).is(locator) | descendant(:img)[attr(:alt).is(locator)]]
    end

    def content(locator)
      child(:"descendant-or-self::*")[current.n.contains(locator)]
    end

    def button(locator)
      button = descendant(:input)[attr(:type).one_of('submit', 'image', 'button')][attr(:id).equals(locator) | attr(:value).is(locator) | attr(:title).is(locator)]
      button += descendant(:button)[attr(:id).equals(locator) | attr(:value).is(locator) | string.n.is(locator) | attr(:title).is(locator)]
      button += descendant(:input)[attr(:type).equals('image')][attr(:alt).is(locator)]
    end

    def link_or_button(locator)
      link(locator) + button(locator)
    end

    def fieldset(locator)
      descendant(:fieldset)[attr(:id).equals(locator) | descendant(:legend)[string.n.is(locator)]]
    end

    def field(locator, options={})
      xpath = descendant(:input, :textarea, :select)[~attr(:type).one_of('submit', 'image', 'hidden')]
      xpath = locate_field(xpath, locator)
      xpath = xpath[attr(:checked)] if options[:checked]
      xpath = xpath[~attr(:checked)] if options[:unchecked]
      xpath = xpath[field_value(options[:with])] if options.has_key?(:with)
      xpath
    end

    def fillable_field(locator, options={})
      xpath = descendant(:input, :textarea)[~attr(:type).one_of('submit', 'image', 'radio', 'checkbox', 'hidden', 'file')]
      xpath = locate_field(xpath, locator)
      xpath = xpath[field_value(options[:with])] if options.has_key?(:with)
      xpath
    end

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

    def checkbox(locator, options={})
      xpath = locate_field(descendant(:input)[attr(:type).equals('checkbox')], locator)
    end

    def radio_button(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('radio')], locator)
    end

    def file_field(locator, options={})
      locate_field(descendant(:input)[attr(:type).equals('file')], locator)
    end

    def optgroup(name)
      descendant(:optgroup)[attr(:label).is(name)]
    end

    def option(name)
      descendant(:option)[string.n.is(name)]
    end

    def table(locator, options={})
      xpath = descendant(:table)[attr(:id).equals(locator) | descendant(:caption).contains(locator)]
      xpath = xpath[table_rows(options[:rows])] if options[:rows]
      xpath
    end

    def table_rows(rows)
      row_conditions = descendant(:tr)[table_row(rows.first)]
      rows.drop(1).each do |row|
        row_conditions = row_conditions.next_sibling(:tr)[table_row(row)]
      end
      row_conditions
    end

    def table_row(cells)
      cell_conditions = child(:td, :th)[string.n.equals(cells.first)]
      cells.drop(1).each do |cell|
        cell_conditions = cell_conditions.next_sibling(:td, :th)[string.n.equals(cell)]
      end
      cell_conditions
    end

  protected

    def locate_field(xpath, locator)
      locate_field = xpath[attr(:id).equals(locator) | attr(:name).equals(locator) | attr(:id).equals(anywhere(:label)[string.n.is(locator)].attr(:for))]
      locate_field += descendant(:label)[string.n.is(locator)].descendant(xpath)
    end

    def field_value(value)
      (string.n.is(value) & tag(:textarea)) | (attr(:value).equals(value) & ~tag(:textarea))
    end

  end
end
