module ReverseAdoc
  module Converters
    module Table
      def self.convert(converter : Converter, node : XML::Node) : String
        result = String.build do |io|
          io << "\n\n|===\n"

          # Process thead, tbody, tfoot, or direct tr children
          node.children.each do |child|
            case child.name
            when "thead"
              io << converter.process_node(child)
            when "tbody", "tfoot"
              io << converter.process_node(child)
            when "tr"
              io << Converters::TableRow.convert(converter, child, 0)
            end
          end

          io << "|===\n\n"
        end
        result
      end
    end

    module TableSection
      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32, header : Bool = false) : String
        result = String.build do |io|
          node.children.each do |child|
            next unless child.name == "tr"
            io << Converters::TableRow.convert(converter, child, list_depth)
          end
          io << "\n" if header
        end
        result
      end
    end

    module TableRow
      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32) : String
        result = String.build do |io|
          node.children.each do |child|
            next unless child.name == "th" || child.name == "td"
            content = converter.process_children(child).strip
            io << "| #{content} "
          end
          io << "\n"
        end
        result
      end
    end

    module TableCell
      def self.convert(converter : Converter, node : XML::Node, header : Bool = false) : String
        content = converter.process_children(node).strip
        "| #{content} "
      end
    end
  end
end
