module ReverseAdoc
  module Converters
    module HorizontalRule
      def self.convert(converter : Converter, node : XML::Node) : String
        "\n\n'''\n\n"
      end
    end

    module Break
      def self.convert(converter : Converter, node : XML::Node) : String
        " +\n"
      end
    end

    module Superscript
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "^#{content}^"
      end
    end

    module Subscript
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "~#{content}~"
      end
    end

    module Strikethrough
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "[.line-through]##{content}#"
      end
    end
  end
end
