module ReverseAdoc
  module Converters
    module Code
      def self.convert(converter : Converter, node : XML::Node) : String
        # If the parent is a <pre>, let Pre handle it
        parent = node.parent
        if parent && parent.name == "pre"
          return node.content || ""
        end

        content = (node.content || "").strip
        return "" if content.empty?
        "`#{content}`"
      end
    end
  end
end
