require "./spec_helper"

describe ReverseAdoc::Docx do
  describe ".docx_xml_to_html" do
    it "converts a simple Word XML paragraph to HTML" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:t>Hello World</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      XML

      html = ReverseAdoc::Docx.docx_xml_to_html(xml)
      html.should contain("<p>Hello World</p>")
    end

    it "converts bold text" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Bold</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      XML

      html = ReverseAdoc::Docx.docx_xml_to_html(xml)
      html.should contain("<strong>Bold</strong>")
    end

    it "converts headings" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:pPr>
              <w:pStyle w:val="Heading1"/>
            </w:pPr>
            <w:r>
              <w:t>My Title</w:t>
            </w:r>
          </w:p>
        </w:body>
      </w:document>
      XML

      html = ReverseAdoc::Docx.docx_xml_to_html(xml)
      html.should contain("<h1>My Title</h1>")
    end

    it "converts tables" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:tbl>
            <w:tr>
              <w:tc>
                <w:p><w:r><w:t>Cell</w:t></w:r></w:p>
              </w:tc>
            </w:tr>
          </w:tbl>
        </w:body>
      </w:document>
      XML

      html = ReverseAdoc::Docx.docx_xml_to_html(xml)
      html.should contain("<table>")
      html.should contain("<td>")
      html.should contain("Cell")
    end
  end

  describe "end-to-end via docx_xml_to_html + convert" do
    it "converts Word XML to AsciiDoc" do
      xml = <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
        <w:body>
          <w:p>
            <w:pPr><w:pStyle w:val="Heading1"/></w:pPr>
            <w:r><w:t>Document Title</w:t></w:r>
          </w:p>
          <w:p>
            <w:r><w:t>A simple paragraph.</w:t></w:r>
          </w:p>
        </w:body>
      </w:document>
      XML

      html = ReverseAdoc::Docx.docx_xml_to_html(xml)
      result = ReverseAdoc.convert(html)
      result.should contain("= Document Title")
      result.should contain("A simple paragraph.")
    end
  end
end
