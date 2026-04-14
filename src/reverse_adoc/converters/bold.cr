module ReverseAdoc
  module Converters
    module Bold
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        "*#{content}*"
      end
    end
  end
end
