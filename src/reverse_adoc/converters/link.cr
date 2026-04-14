module ReverseAdoc
  module Converters
    module Link
      def self.convert(converter : Converter, node : XML::Node) : String
        href = node["href"]? || ""
        content = converter.process_children(node).strip
        return content if href.empty?

        # Use URL macro format for http/https, link: for others
        if href.starts_with?("http://") || href.starts_with?("https://")
          if content.empty? || content == href
            href
          else
            "#{href}[#{content}]"
          end
        elsif href.starts_with?("mailto:")
          "#{href}[#{content}]"
        else
          if content.empty?
            "link:#{href}[]"
          else
            "link:#{href}[#{content}]"
          end
        end
      end
    end
  end
end
