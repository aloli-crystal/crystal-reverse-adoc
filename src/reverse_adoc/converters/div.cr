module ReverseAdoc
  module Converters
    module Div
      ADMONITION_CLASSES = {
        "note"       => "NOTE",
        "tip"        => "TIP",
        "important"  => "IMPORTANT",
        "warning"    => "WARNING",
        "caution"    => "CAUTION",
        "admonition" => "NOTE",
      }

      def self.convert(converter : Converter, node : XML::Node, list_depth : Int32) : String
        klass = node["class"]? || ""

        # Check for admonition classes
        ADMONITION_CLASSES.each do |css_class, adoc_type|
          if klass.includes?(css_class)
            content = converter.process_children(node, list_depth).strip
            return "\n\n#{adoc_type}: #{content}\n\n" unless content.empty?
            return ""
          end
        end

        # Default: just process children
        converter.process_children(node, list_depth)
      end
    end
  end
end
