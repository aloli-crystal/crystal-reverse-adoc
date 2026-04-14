module ReverseAdoc
  module Converters
    module Paragraph
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "\n\n#{content}\n\n"
      end
    end
  end
end
