# frozen_string_literal: true

require 'pdf/info'
require_relative 'utils'

module Jekyll
  module Pandoc
    # Mixin to take a single page PDF and generate a ready for print
    # PDF.
    #
    # The implementation uses a Liquid template written in TeX to
    # import the original PDF and generate a new PDF with the printing
    # layout.
    module Printing
      # How many pages fit per sheet.  To obtain them divide the sheet
      # size value by the page size value.  An A0 sheet fits 128 A7 pages.
      #
      # @return [Hash]
      SHEET_SIZES = {
        a7: 2,
        a6: 4,
        a5: 8,
        a4: 16,
        a3: 32,
        a2: 64,
        a1: 128,
        a0: 256
      }.freeze

      # Which sheet sizes are landscaped
      #
      # @return [Array]
      LANDSCAPE = [2, 8, 32, 128].freeze

      private

      # Options for the template
      #
      # @return [Array]
      def options
        @options ||= [('landscape' if landscape?)].compact
      end

      # LaTeX template for processing a PDF and rearranging its pages
      #
      # @return [Liquid::Template]
      def template
        @template ||= Liquid::Template.parse(File.read(File.join(File.dirname(__FILE__), 'printing.latex.liquid')))
      end

      # Generates an array of pages in the order they need to be printed.
      # This depends on the printer implementation.
      #
      # @return [Array]
      def pages
        raise NotImplementError
      end

      # Sheet size.  The sheet is the paper where the pages are printed
      # on.
      #
      # @return [Symbol]
      def sheetsize
        @sheetsize ||= site.config.dig('pandoc', 'printing', 'sheetsize').to_sym.tap do |x|
          raise NoMethodError unless SHEET_SIZES.key? x
        end
      rescue NoMethodError
        Jekyll.logger.warn "Sheetsize is missing or incorrect, please add one of #{SHEET_SIZES.keys.join(', ')} to _config.yml"
        raise ArgumentError, 'Please configure the jekyll-pandoc-multiple-formats plugin'
      end

      # Page size is the same as papersize
      #
      # @return [Symbol]
      def pagesize
        @pagesize ||= site.config['pandoc'].papersize.tap do |x|
          raise NoMethodError unless SHEET_SIZES.key? x
        end
      rescue NoMethodError
        Jekyll.logger.warn "Papersize is missing or incorrect, please add one of #{SHEET_SIZES.keys.join(', ')} to PDF format in _config.yml"
        raise ArgumentError, 'Please configure the jekyll-pandoc-multiple-formats plugin'
      end

      # Represents a blank page
      #
      # @return [String]
      def blank_page
        @blank_page ||= '{}'
      end

      # Page count in the source PDF
      #
      # PDFInfo requires `pdfinfo` from Poppler installed.
      #
      # XXX: It may be possible to extract the metadata just by
      # `#binread`ing the file, but apparently PDF has many ways to
      # inform the page count, so we're adding this dependency for
      # simplicity.
      #
      # @return [Integer]
      def page_count
        @page_count ||= PDF::Info.new(document.source_document.tempfile.path).metadata[:page_count]
      end

      # Pages per sheet
      #
      # @return [Integer]
      def nup
        @nup ||= SHEET_SIZES[sheetsize] / SHEET_SIZES[pagesize]
      end

      # Information for rendering the template
      #
      # @return [Hash]
      def template_payload
        @template_payload ||=
          {
            'nup' => nup,
            'sheetsize' => "#{sheetsize}paper",
            'options' => options,
            'path' => document.source_document.tempfile.path,
            'pages' => pages
          }
      end

      # Renders the template.  We're following Jekyll's process where
      # templates are rendered and written in different steps.
      #
      # @return [String]
      def render_template
        template.render(**template_payload)
      end

      # Generates a new PDF and writes it into the site.
      #
      # @return [nil]
      def convert(_)
        Dir.mktmpdir do |dir|
          Dir.chdir dir do
            Open3.popen2e(Utils.tectonic, '-') do |stdin, stdout, thread|
              stdin.puts render_template
              stdin.close
              stderr = stdout.read

              # Wait for the process to finish and raise an error if it fails
              unless thread.value.success?
                raise StandardError, "I couldn't generate #{document.relative_path}, the process said: #{stderr}"
              end

              # Copy the contents to the tempfile
              IO.copy_stream(File.open('texput.pdf'), document.tempfile.path)
            end
          end
        end
      end

      # Detect if sheet should be printed in landscape mode.
      #
      # @return [Boolean]
      def landscape?
        LANDSCAPE.include? nup
      end
    end
  end
end
