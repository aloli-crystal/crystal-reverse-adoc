require "./spec_helper"

# Baseline check: the converter runs without raising on trivial input
# and produces the minimal expected output.
describe "Integration · sanity" do
  it "converts a whitespace-only document to whitespace-only output" do
    # Note: the underlying `XML.parse_html` raises `Document is empty`
    # on a fully empty string, which is a separate bug to fix. Here
    # we check the smallest non-empty input that the parser accepts.
    IntegrationHelper.convert("<p> </p>").strip.size.should be <= 1
  end

  it "always ends non-empty output with a trailing newline" do
    result = IntegrationHelper.convert("<p>Hello.</p>")
    result.ends_with?("\n").should be_true
  end

  it "preserves author words from a paragraph" do
    result = IntegrationHelper.convert(
      "<p>This paragraph mentions Paris, Crystal and HTML by name.</p>"
    )
    result.should contain("Paris")
    result.should contain("Crystal")
    result.should contain("HTML")
  end

  it "leaves no stray HTML tags in the output of a mixed paragraph" do
    result = IntegrationHelper.convert(
      "<p>A <strong>bold</strong> and <em>italic</em> phrase.</p>"
    )
    # All HTML tags should be consumed and converted to AsciiDoc markup.
    result.should_not contain("<strong>")
    result.should_not contain("</strong>")
    result.should_not contain("<em>")
    result.should_not contain("<p>")
    # AsciiDoc markers are present instead.
    result.should contain("*bold*")
    result.should contain("_italic_")
  end
end
