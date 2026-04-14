module ReverseAdoc
  module Converters
    module Image
      def self.convert(converter : Converter, node : XML::Node) : String
        src = node["src"]? || ""
        alt = node["alt"]? || ""
        return "" if src.empty?
        "image::#{src}[#{alt}]"
      end
    end
  end
end
