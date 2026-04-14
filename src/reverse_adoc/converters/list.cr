module ReverseAdoc
  module Converters
    module UnorderedList
      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32) : String
        result = String.build do |io|
          io << "\n" if list_depth == 0
          node.children.each do |child|
            next unless child.name == "li"
            io << converter.process_node(child, list_depth + 1)
          end
          io << "\n" if list_depth == 0
        end
        result
      end
    end

    module OrderedList
      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32) : String
        result = String.build do |io|
          io << "\n" if list_depth == 0
          node.children.each do |child|
            next unless child.name == "li"
            io << converter.process_node(child, list_depth + 1)
          end
          io << "\n" if list_depth == 0
        end
        result
      end
    end

    module ListItem
      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32) : String
        parent = node.parent
        marker = if parent && parent.name == "ol"
                   "." * list_depth
                 else
                   "*" * list_depth
                 end

        # Process children, handling nested lists separately
        content_parts = String.build do |io|
          node.children.each do |child|
            if child.name == "ul" || child.name == "ol"
              io << converter.process_node(child, list_depth)
            else
              io << converter.process_node(child, list_depth)
            end
          end
        end

        content = content_parts.strip
        lines = content.split('\n')
        first_line = lines.first? || ""

        result = String.build do |io|
          io << "#{marker} #{first_line}\n"
          lines.skip(1).each do |line|
            if line.starts_with?("*") || line.starts_with?(".")
              io << line << "\n"
            elsif !line.strip.empty?
              io << line << "\n"
            end
          end
        end
        result
      end
    end
  end
end
