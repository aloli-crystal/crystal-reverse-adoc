module ReverseAdoc
  module Converters
    module Heading
      def self.convert(converter : Converter, node : XML::Node, level : Int32) : String
        content = converter.process_children(node).strip
        return "" if content.empty?
        prefix = "=" * level
        "\n\n#{prefix} #{content}\n\n"
      end
    end
  end
end
