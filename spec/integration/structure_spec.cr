require "./spec_helper"

# Document-level structural invariants that should hold for any
# reasonable AsciiDoc output from the HTML converter.
describe "Integration · document structure" do
  it "separates two consecutive paragraphs with a blank line" do
    result = IntegrationHelper.convert(
      "<p>First paragraph.</p><p>Second paragraph.</p>"
    )
    result.should contain("First paragraph.\n\nSecond paragraph.")
  end

  it "separates a heading from the following paragraph with a blank line" do
    result = IntegrationHelper.convert("<h1>Title</h1><p>Body.</p>")
    # The heading line is followed by exactly one blank line (i.e. two \n)
    # then the body — regression guard for over-eager newline collapsing.
    result.should contain("= Title\n\nBody.")
  end

  it "emits the document title before any sub-section" do
    result = IntegrationHelper.convert(
      "<h1>Main Title</h1><p>Body.</p><h2>Section</h2><p>Sub.</p>"
    )
    title_idx = result.index("= Main Title")
    section_idx = result.index("== Section")
    title_idx.should_not be_nil
    section_idx.should_not be_nil
    (title_idx.not_nil! < section_idx.not_nil!).should be_true
  end

  it "produces the same output when called twice (determinism)" do
    html = "<h1>T</h1><p>A <strong>paragraph</strong>.</p>"
    a = IntegrationHelper.convert(html)
    b = IntegrationHelper.convert(html)
    a.should eq(b)
  end

  it "ignores <script>, <style>, <meta> and <link> tags in <head>" do
    html = <<-HTML
    <html>
    <head>
      <title>ignored</title>
      <meta charset="utf-8"/>
      <link rel="stylesheet" href="x.css"/>
      <style>body { color: red; }</style>
      <script>alert('boom')</script>
    </head>
    <body>
      <p>Visible body text.</p>
    </body>
    </html>
    HTML
    result = IntegrationHelper.convert(html)
    result.should contain("Visible body text.")
    # None of the <head> content should leak into the AsciiDoc output
    result.should_not contain("ignored")
    result.should_not contain("x.css")
    result.should_not contain("body { color")
    result.should_not contain("alert(")
  end

  it "drops HTML comments" do
    result = IntegrationHelper.convert(
      "<p>Before<!-- dropped comment -->after.</p>"
    )
    result.should contain("Before")
    result.should contain("after.")
    result.should_not contain("dropped comment")
    result.should_not contain("<!--")
  end
end
