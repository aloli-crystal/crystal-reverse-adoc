require "xml"

module ReverseAdoc
  class Converter
    property tag_border : Bool

    def initialize(@tag_border : Bool = false)
    end

    # Convert an HTML string to AsciiDoc.
    def convert(html : String) : String
      doc = XML.parse_html(html)
      body = find_body(doc) || doc
      result = process_children(body)
      cleanup(result)
    end

    # Find the <body> element, or return nil if not present.
    private def find_body(doc : XML::Node) : XML::Node?
      find_node(doc, "body")
    end

    private def find_node(node : XML::Node, name : String) : XML::Node?
      return node if node.name == name
      node.children.each do |child|
        result = find_node(child, name)
        return result if result
      end
      nil
    end

    # Process all children of a node and return combined AsciiDoc.
    def process_children(node : XML::Node, list_depth : Int32 = 0) : String
      result = String.build do |io|
        node.children.each do |child|
          io << process_node(child, list_depth)
        end
      end
      result
    end

    # Process a single node and return AsciiDoc.
    def process_node(node : XML::Node, list_depth : Int32 = 0) : String
      case node.type
      when .text_node?
        process_text(node)
      when .element_node?
        convert_element(node, list_depth)
      when .comment_node?
        ""
      else
        ""
      end
    end

    # Process a text node.
    private def process_text(node : XML::Node) : String
      text = node.content || ""

      # Check if we're inside a <pre> block
      if inside_pre?(node)
        return text
      end

      # Collapse whitespace for normal text
      text = text.gsub(/\s+/, " ")

      # Don't return purely whitespace between block elements
      parent = node.parent
      if parent && block_element?(parent)
        text = text.strip if text.strip.empty?
      end

      text
    end

    # Check if a node is inside a <pre> element.
    private def inside_pre?(node : XML::Node) : Bool
      current = node.parent
      while current
        return true if current.name == "pre"
        current = current.parent
      end
      false
    end

    # Convert an element node based on its tag name.
    private def convert_element(node : XML::Node, list_depth : Int32) : String
      tag = node.name.downcase
      case tag
      when "h1"                              then Converters::Heading.convert(self, node, 1)
      when "h2"                              then Converters::Heading.convert(self, node, 2)
      when "h3"                              then Converters::Heading.convert(self, node, 3)
      when "h4"                              then Converters::Heading.convert(self, node, 4)
      when "h5"                              then Converters::Heading.convert(self, node, 5)
      when "h6"                              then Converters::Heading.convert(self, node, 6)
      when "p"                               then Converters::Paragraph.convert(self, node)
      when "strong", "b"                     then Converters::Bold.convert(self, node)
      when "em", "i"                         then Converters::Italic.convert(self, node)
      when "code"                            then Converters::Code.convert(self, node)
      when "pre"                             then Converters::Pre.convert(self, node)
      when "a"                               then Converters::Link.convert(self, node)
      when "img"                             then Converters::Image.convert(self, node)
      when "ul"                              then Converters::UnorderedList.convert(self, node, list_depth)
      when "ol"                              then Converters::OrderedList.convert(self, node, list_depth)
      when "li"                              then Converters::ListItem.convert(self, node, list_depth)
      when "dl"                              then Converters::DefinitionList.convert(self, node)
      when "dt"                              then Converters::DefinitionTerm.convert(self, node)
      when "dd"                              then Converters::DefinitionDescription.convert(self, node)
      when "table"                           then Converters::Table.convert(self, node)
      when "thead"                           then Converters::TableSection.convert(self, node, list_depth, header: true)
      when "tbody", "tfoot"                  then Converters::TableSection.convert(self, node, list_depth, header: false)
      when "tr"                              then Converters::TableRow.convert(self, node, list_depth)
      when "th"                              then Converters::TableCell.convert(self, node, header: true)
      when "td"                              then Converters::TableCell.convert(self, node, header: false)
      when "blockquote"                      then Converters::Blockquote.convert(self, node)
      when "hr"                              then Converters::HorizontalRule.convert(self, node)
      when "br"                              then Converters::Break.convert(self, node)
      when "sup"                             then Converters::Superscript.convert(self, node)
      when "sub"                             then Converters::Subscript.convert(self, node)
      when "del", "s"                        then Converters::Strikethrough.convert(self, node)
      when "div"                             then Converters::Div.convert(self, node, list_depth)
      when "span"                            then process_children(node, list_depth)
      when "html"                            then process_children(node, list_depth)
      when "body"                            then process_children(node, list_depth)
      when "head"                            then ""
      when "script", "style", "meta", "link" then ""
      else
        # Pass through unknown elements, just process their children
        process_children(node, list_depth)
      end
    end

    # Clean up the final output.
    private def cleanup(text : String) : String
      text = text
        .gsub(/\n{3,}/, "\n\n") # No more than 2 consecutive newlines
        .gsub(/\A\n+/, "")      # No leading newlines
        .gsub(/\n+\z/, "")      # No trailing newlines
      text + "\n"
    end

    # Check if a node is a block-level element.
    def block_element?(node : XML::Node) : Bool
      BLOCK_ELEMENTS.includes?(node.name.downcase)
    end

    BLOCK_ELEMENTS = Set{
      "p", "div", "h1", "h2", "h3", "h4", "h5", "h6",
      "ul", "ol", "li", "dl", "dt", "dd",
      "table", "thead", "tbody", "tfoot", "tr", "th", "td",
      "blockquote", "pre", "hr", "br",
      "article", "section", "aside", "nav", "header", "footer", "main",
      "figure", "figcaption",
    }
  end
end
