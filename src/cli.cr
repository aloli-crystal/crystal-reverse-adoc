require "option_parser"
require "./reverse_adoc"

module ReverseAdoc
  module CLI
    def self.run(args = ARGV)
      output_file : String? = nil

      parser = OptionParser.new do |p|
        p.banner = "Usage: reverse-adoc [options] INPUT_FILE"

        p.on("-o OUTPUT", "--output OUTPUT", "Write output to file") do |path|
          output_file = path
        end

        p.on("-v", "--version", "Show version") do
          puts "reverse-adoc #{ReverseAdoc::VERSION} (port of reverse_adoc #{ReverseAdoc::UPSTREAM_VERSION})"
          exit 0
        end

        p.on("-h", "--help", "Show help") do
          puts p
          exit 0
        end
      end

      parser.parse(args)

      if args.empty?
        STDERR.puts "Error: no input file specified"
        STDERR.puts parser
        exit 1
      end

      input_file = args.first
      unless File.exists?(input_file)
        STDERR.puts "Error: file not found: #{input_file}"
        exit 1
      end

      result = if input_file.ends_with?(".docx")
                 ReverseAdoc.convert_docx(input_file)
               else
                 html = File.read(input_file)
                 ReverseAdoc.convert(html)
               end

      if outpath = output_file
        File.write(outpath, result)
      else
        print result
      end
    end
  end
end

ReverseAdoc::CLI.run
