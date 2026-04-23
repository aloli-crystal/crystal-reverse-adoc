require "spec"
require "../../src/reverse_adoc"

# Integration-test helpers: drive `ReverseAdoc` end-to-end against
# realistic HTML documents (fragments loaded from disk or inlined
# from a string) and expose primitives for structural assertions on
# the AsciiDoc output.
#
# The unit specs (`spec/reverse_adoc_spec.cr`) already cover each
# HTML tag in isolation; these integration specs complement them by
# round-tripping a README- or article-shaped HTML blob through the
# real converter and checking the document-level invariants.
module IntegrationHelper
  # Converts the given HTML source to AsciiDoc.
  def self.convert(html : String) : String
    ReverseAdoc.convert(html)
  end

  # Reads a fixture file from `spec/integration/fixtures/` and returns
  # its content as a string.
  def self.fixture(name : String) : String
    File.read(File.join(__DIR__, "fixtures", name))
  end
end
