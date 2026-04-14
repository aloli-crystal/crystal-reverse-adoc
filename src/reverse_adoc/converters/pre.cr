module ReverseAdoc
  module Converters
    module Pre
      def self.convert(converter : Converter, node : XML::Node) : String
        code_node = find_code_child(node)
        content = if code_node
                    code_node.content || ""
                  else
                    node.content || ""
                  end

        # Detect language from class attribute on <code> or <pre>
        language = detect_language(code_node || node)

        # Remove trailing newline from content but preserve internal structure
        content = content.chomp

        lang_attr = language ? "[source,#{language}]" : "[source]"

        "\n\n#{lang_attr}\n----\n#{content}\n----\n\n"
      end

      private def self.find_code_child(node : XML::Node) : XML::Node?
        node.children.each do |child|
          return child if child.name == "code"
        end
        nil
      end

      private def self.detect_language(node : XML::Node) : String?
        klass = node["class"]? || ""
        # Common patterns: language-ruby, lang-ruby, highlight-ruby, brush:ruby
        if klass =~ /(?:language|lang|highlight)-(\w+)/
          return $1
        end
        if klass =~ /brush:\s*(\w+)/
          return $1
        end
        # Just a bare class name that looks like a language
        known = {"ruby", "crystal", "python", "javascript", "js", "html", "css",
                 "java", "c", "cpp", "go", "rust", "shell", "bash", "sh",
                 "json", "yaml", "xml", "sql", "typescript", "ts"}
        klass.split(/\s+/).each do |cls|
          return cls if known.includes?(cls)
        end
        nil
      end
    end
  end
end
