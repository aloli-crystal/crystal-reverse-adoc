require "xml"
require "./reverse_adoc/converter"
require "./reverse_adoc/converters/*"
require "./reverse_adoc/docx"

module ReverseAdoc
  VERSION          = "2.0.0"
  UPSTREAM_VERSION = "2.0.0"

  # Convert an HTML string to AsciiDoc.
  def self.convert(html : String, **options) : String
    Converter.new(**options).convert(html)
  end

  # Convert a .docx file to AsciiDoc.
  def self.convert_docx(path : String, **options) : String
    Docx.convert(path, **options)
  end
end
