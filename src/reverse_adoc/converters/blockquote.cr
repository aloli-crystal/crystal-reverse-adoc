module ReverseAdoc
  module Converters
    module Blockquote
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "\n\n____\n#{content}\n____\n\n"
      end
    end
  end
end
