require "./spec_helper"

describe ReverseAdoc do
  describe ".convert" do
    describe "edge cases" do
      it "returns an empty string for an empty input" do
        ReverseAdoc.convert("").should eq ""
      end

      it "returns an empty string for a whitespace-only input" do
        ReverseAdoc.convert("   \n  \t\n").should eq ""
      end
    end

    describe "headings" do
      it "converts h1" do
        ReverseAdoc.convert("<h1>Title</h1>").should eq "= Title\n"
      end

      it "converts h2" do
        ReverseAdoc.convert("<h2>Title</h2>").should eq "== Title\n"
      end

      it "converts h3" do
        ReverseAdoc.convert("<h3>Title</h3>").should eq "=== Title\n"
      end

      it "converts h4" do
        ReverseAdoc.convert("<h4>Title</h4>").should eq "==== Title\n"
      end

      it "converts h5" do
        ReverseAdoc.convert("<h5>Title</h5>").should eq "===== Title\n"
      end

      it "converts h6" do
        ReverseAdoc.convert("<h6>Title</h6>").should eq "====== Title\n"
      end
    end

    describe "paragraphs" do
      it "converts a simple paragraph" do
        ReverseAdoc.convert("<p>Hello world</p>").should eq "Hello world\n"
      end

      it "converts multiple paragraphs" do
        result = ReverseAdoc.convert("<p>First</p><p>Second</p>")
        result.should eq "First\n\nSecond\n"
      end
    end

    describe "inline formatting" do
      it "converts strong/bold" do
        ReverseAdoc.convert("<p><strong>bold</strong></p>").should eq "*bold*\n"
      end

      it "converts b tag" do
        ReverseAdoc.convert("<p><b>bold</b></p>").should eq "*bold*\n"
      end

      it "converts em/italic" do
        ReverseAdoc.convert("<p><em>italic</em></p>").should eq "_italic_\n"
      end

      it "converts i tag" do
        ReverseAdoc.convert("<p><i>italic</i></p>").should eq "_italic_\n"
      end

      it "converts inline code" do
        ReverseAdoc.convert("<p><code>code</code></p>").should eq "`code`\n"
      end

      it "converts superscript" do
        ReverseAdoc.convert("<p><sup>super</sup></p>").should eq "^super^\n"
      end

      it "converts subscript" do
        ReverseAdoc.convert("<p><sub>sub</sub></p>").should eq "~sub~\n"
      end

      it "converts strikethrough with del" do
        ReverseAdoc.convert("<p><del>deleted</del></p>").should eq "[.line-through]#deleted#\n"
      end

      it "converts strikethrough with s" do
        ReverseAdoc.convert("<p><s>struck</s></p>").should eq "[.line-through]#struck#\n"
      end
    end

    describe "code blocks" do
      it "converts pre/code blocks" do
        html = "<pre><code>puts 'hello'</code></pre>"
        result = ReverseAdoc.convert(html)
        result.should contain("[source]")
        result.should contain("----")
        result.should contain("puts 'hello'")
      end

      it "detects language from class" do
        html = %(<pre><code class="language-ruby">puts 'hello'</code></pre>)
        result = ReverseAdoc.convert(html)
        result.should contain("[source,ruby]")
      end

      it "handles pre without code child" do
        html = "<pre>plain text</pre>"
        result = ReverseAdoc.convert(html)
        result.should contain("[source]")
        result.should contain("plain text")
      end
    end

    describe "links" do
      it "converts http links" do
        html = %(<a href="https://example.com">Example</a>)
        ReverseAdoc.convert(html).should eq "https://example.com[Example]\n"
      end

      it "converts bare http links" do
        html = %(<a href="https://example.com">https://example.com</a>)
        ReverseAdoc.convert(html).should eq "https://example.com\n"
      end

      it "converts relative links" do
        html = %(<a href="page.html">Page</a>)
        ReverseAdoc.convert(html).should eq "link:page.html[Page]\n"
      end
    end

    describe "images" do
      it "converts img tags" do
        html = %(<img src="photo.jpg" alt="A photo">)
        ReverseAdoc.convert(html).should eq "image::photo.jpg[A photo]\n"
      end
    end

    describe "unordered lists" do
      it "converts simple list" do
        html = "<ul><li>One</li><li>Two</li></ul>"
        result = ReverseAdoc.convert(html)
        result.should contain("* One")
        result.should contain("* Two")
      end

      it "converts nested lists" do
        html = "<ul><li>One<ul><li>Nested</li></ul></li></ul>"
        result = ReverseAdoc.convert(html)
        result.should contain("* One")
        result.should contain("** Nested")
      end
    end

    describe "ordered lists" do
      it "converts simple ordered list" do
        html = "<ol><li>First</li><li>Second</li></ol>"
        result = ReverseAdoc.convert(html)
        result.should contain(". First")
        result.should contain(". Second")
      end
    end

    describe "definition lists" do
      it "converts dl/dt/dd" do
        html = "<dl><dt>Term</dt><dd>Definition</dd></dl>"
        result = ReverseAdoc.convert(html)
        result.should contain("Term:: Definition")
      end
    end

    describe "tables" do
      it "converts a simple table" do
        html = "<table><tr><td>A</td><td>B</td></tr></table>"
        result = ReverseAdoc.convert(html)
        result.should contain("|===")
        result.should contain("| A")
        result.should contain("| B")
      end

      it "converts table with headers" do
        html = "<table><thead><tr><th>Header</th></tr></thead><tbody><tr><td>Data</td></tr></tbody></table>"
        result = ReverseAdoc.convert(html)
        result.should contain("| Header")
        result.should contain("| Data")
      end
    end

    describe "blockquote" do
      it "converts blockquote" do
        result = ReverseAdoc.convert("<blockquote>Quote text</blockquote>")
        result.should contain("____")
        result.should contain("Quote text")
      end
    end

    describe "horizontal rule" do
      it "converts hr" do
        result = ReverseAdoc.convert("<hr>")
        result.should contain("'''")
      end
    end

    describe "line break" do
      it "converts br" do
        result = ReverseAdoc.convert("<p>Line one<br>Line two</p>")
        result.should contain(" +\n")
      end
    end

    describe "admonitions" do
      it "converts div with note class" do
        html = %(<div class="note">Important note</div>)
        result = ReverseAdoc.convert(html)
        result.should contain("NOTE: Important note")
      end

      it "converts div with admonition class" do
        html = %(<div class="admonition">Some warning</div>)
        result = ReverseAdoc.convert(html)
        result.should contain("NOTE: Some warning")
      end

      it "converts div with warning class" do
        html = %(<div class="warning">Be careful</div>)
        result = ReverseAdoc.convert(html)
        result.should contain("WARNING: Be careful")
      end
    end

    describe "complete document" do
      it "converts a full HTML document" do
        html = <<-HTML
        <html>
        <head><title>Test</title></head>
        <body>
          <h1>Title</h1>
          <p>A paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
          <ul>
            <li>Item 1</li>
            <li>Item 2</li>
          </ul>
          <pre><code class="language-crystal">puts "Hello"</code></pre>
        </body>
        </html>
        HTML

        result = ReverseAdoc.convert(html)
        result.should contain("= Title")
        result.should contain("*bold*")
        result.should contain("_italic_")
        result.should contain("* Item 1")
        result.should contain("[source,crystal]")
        result.should contain(%(puts "Hello"))
      end
    end

    describe "unknown elements" do
      it "passes through content of unknown elements" do
        result = ReverseAdoc.convert("<article><p>Content</p></article>")
        result.should contain("Content")
      end
    end

    describe "whitespace handling" do
      it "does not produce excessive blank lines" do
        html = "<p>One</p><p>Two</p><p>Three</p>"
        result = ReverseAdoc.convert(html)
        result.should_not contain("\n\n\n")
      end
    end
  end

  describe "VERSION" do
    it "has a version" do
      ReverseAdoc::VERSION.should eq "2.0.0.3"
    end

    it "has an upstream version" do
      ReverseAdoc::UPSTREAM_VERSION.should eq "2.0.0"
    end
  end
end
