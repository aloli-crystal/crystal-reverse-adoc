require "xml"
require "./reverse_adoc/converter"
require "./reverse_adoc/converters/*"
require "./reverse_adoc/docx"

module ReverseAdoc
  # Lue au compile-time depuis `shard.yml` via le macro `read_file`.
  # Cf. note mémoire `feedback_shard_version_macro.md` (mémoire ALOLI).
  VERSION = {{
              (read_file("#{__DIR__}/../shard.yml")
                .lines
                .find(&.starts_with?("version:")) || "version: 0.0.0")
                .gsub(/^version:\s*/, "")
                .chomp
            }}
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
