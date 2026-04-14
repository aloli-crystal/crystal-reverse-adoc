module ReverseAdoc
  module Converters
    module Italic
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "_#{content}_"
      end
    end
  end
end
