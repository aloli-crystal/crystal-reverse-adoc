module ReverseAdoc
  module Converters
    module DefinitionList
      def self.convert(converter : Converter, node : XML::Node) : String
        "\n\n" + converter.process_children(node) + "\n"
      end
    end

    module DefinitionTerm
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        "#{content}:: "
      end
    end

    module DefinitionDescription
      def self.convert(converter : Converter, node : XML::Node) : String
        content = converter.process_children(node).strip
        "#{content}\n"
      end
    end
  end
end
