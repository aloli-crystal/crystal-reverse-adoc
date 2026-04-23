require "./spec_helper"

# Full document round-trip: convert a realistic HTML article with
# headings, paragraphs, multiple fenced `<pre>` blocks, lists, a
# blockquote, a horizontal rule and a table, then assert the AsciiDoc
# output contains the expected markers for each construct.
describe "Integration · full article-shaped document" do
  it "converts a realistic HTML article into AsciiDoc with every marker" do
    adoc = IntegrationHelper.convert(IntegrationHelper.fixture("article.html"))

    # Document title (level-1 heading) is present
    adoc.should contain("= Crystal is Fast")

    # Level-2 sections
    adoc.should contain("== Installation")
    adoc.should contain("== Hello world")
    adoc.should contain("== Features")
    adoc.should contain("== Compatibility matrix")

    # Level-3 section
    adoc.should contain("=== Learn more")

    # Inline formatting
    adoc.should contain("*compiled*")
    adoc.should contain("_static_")
    adoc.should contain("`type inference`")

    # Links preserved with URL + label (AsciiDoc syntax: link:url[text]
    # or url[text])
    adoc.should contain("https://crystal-lang.org")
    adoc.should contain("official site")
    adoc.should contain("tutorial")
    adoc.should contain("stdlib docs")

    # Pre/code blocks with language
    adoc.should contain("brew install crystal")
    adoc.should contain(%q(puts "Hello, world!"))
    # Code fences present
    adoc.should contain("----")

    # Unordered list items
    adoc.should contain("Native code")
    adoc.should contain("Ruby-like syntax")
    adoc.should contain("Zero-cost abstractions")

    # Blockquote marker
    adoc.should contain("____")

    # Thematic break
    adoc.should contain("'''")

    # Table content
    adoc.should contain("|===")
    adoc.should contain("Linux")
    adoc.should contain("macOS")
    adoc.should contain("Windows")
    adoc.should contain("Best-effort")

    # No leaked HTML tags (regression guard)
    adoc.should_not contain("<h1>")
    adoc.should_not contain("<p>")
    adoc.should_not contain("<strong>")
    adoc.should_not contain("<em>")
    adoc.should_not contain("<ul>")
    adoc.should_not contain("<table>")
    adoc.should_not contain("<pre>")
    adoc.should_not contain("</html>")
  end
end
