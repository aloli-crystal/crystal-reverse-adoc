require "compress/zip"

module ReverseAdoc
  module Docx
    # Convert a .docx file to AsciiDoc.
    def self.convert(path : String, **options) : String
      xml_content = extract_document_xml(path)
      html = docx_xml_to_html(xml_content)
      ReverseAdoc.convert(html, **options)
    end

    # Extract word/document.xml from the .docx ZIP archive.
    def self.extract_document_xml(path : String) : String
      content = ""
      File.open(path) do |file|
        Compress::Zip::Reader.open(file) do |zip|
          zip.each_entry do |entry|
            if entry.filename == "word/document.xml"
              content = entry.io.gets_to_end
              break
            end
          end
        end
      end
      raise "No word/document.xml found in #{path}" if content.empty?
      content
    end

    # Convert Word XML to a simple HTML structure for processing.
    def self.docx_xml_to_html(xml_content : String) : String
      doc = XML.parse(xml_content)
      body = find_body(doc)
      return "" unless body

      html = String.build do |io|
        io << "<html><body>"
        process_docx_node(body, io)
        io << "</body></html>"
      end
      html
    end

    private def self.find_body(doc : XML::Node) : XML::Node?
      find_node_by_local_name(doc, "body")
    end

    private def self.find_node_by_local_name(node : XML::Node, local_name : String) : XML::Node?
      name = node.name.split(":").last
      return node if name == local_name
      node.children.each do |child|
        result = find_node_by_local_name(child, local_name)
        return result if result
      end
      nil
    end

    private def self.process_docx_node(node : XML::Node, io : IO) : Nil
      node.children.each do |child|
        local_name = child.name.split(":").last
        case local_name
        when "p"
          # Paragraph — check if it's a heading
          heading_level = detect_heading_level(child)
          if heading_level
            io << "<h#{heading_level}>"
            process_docx_runs(child, io)
            io << "</h#{heading_level}>"
          else
            io << "<p>"
            process_docx_runs(child, io)
            io << "</p>"
          end
        when "tbl"
          io << "<table>"
          process_docx_table(child, io)
          io << "</table>"
        else
          process_docx_node(child, io)
        end
      end
    end

    private def self.process_docx_runs(para : XML::Node, io : IO) : Nil
      para.children.each do |child|
        local_name = child.name.split(":").last
        case local_name
        when "r"
          process_run(child, io)
        when "hyperlink"
          # Extract rId for the link — simplified, just output text
          io << "<a>"
          child.children.each do |hc|
            if hc.name.split(":").last == "r"
              process_run(hc, io)
            end
          end
          io << "</a>"
        end
      end
    end

    private def self.process_run(run : XML::Node, io : IO) : Nil
      # Check for bold/italic in rPr
      bold = false
      italic = false
      run.children.each do |child|
        if child.name.split(":").last == "rPr"
          child.children.each do |prop|
            prop_name = prop.name.split(":").last
            bold = true if prop_name == "b"
            italic = true if prop_name == "i"
          end
        end
      end

      io << "<strong>" if bold
      io << "<em>" if italic

      run.children.each do |child|
        local_name = child.name.split(":").last
        case local_name
        when "t"
          io << (child.content || "")
        when "br"
          io << "<br>"
        when "tab"
          io << "\t"
        end
      end

      io << "</em>" if italic
      io << "</strong>" if bold
    end

    private def self.detect_heading_level(para : XML::Node) : Int32?
      para.children.each do |child|
        if child.name.split(":").last == "pPr"
          child.children.each do |prop|
            if prop.name.split(":").last == "pStyle"
              val = prop["w:val"]? || prop["val"]? || ""
              if val =~ /Heading(\d)/i
                level = $1.to_i
                return level if level >= 1 && level <= 6
              end
            end
          end
        end
      end
      nil
    end

    private def self.process_docx_table(table : XML::Node, io : IO) : Nil
      table.children.each do |child|
        if child.name.split(":").last == "tr"
          io << "<tr>"
          child.children.each do |cell|
            if cell.name.split(":").last == "tc"
              io << "<td>"
              process_docx_node(cell, io)
              io << "</td>"
            end
          end
          io << "</tr>"
        end
      end
    end
  end
end
