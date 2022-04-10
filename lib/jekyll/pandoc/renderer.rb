# frozen_string_literal: true

require_relative 'paru_helper'
require_relative 'utils'

module Jekyll
  module Pandoc
    # Renderer for Pandoc formats.  Contrary to Jekyll's workflow, the
    # renderer doesn't call a {Jekyll::Converter}, because they convert
    # based on origin format and not destination format.
    class Renderer < Jekyll::Renderer
      # Converts document using pandoc.  Pandoc needs the document
      # content, maybe already rendered with Liquid, and the document
      # metadata.
      #
      # For binary formats, the conversion string will be empty, and we
      # write the output file on a temporary file that is later copied
      # to the destination by {Jekyll::Pandoc::Document#write}.
      #
      # @param content [String]
      # @return [String] empty string when binary file
      def convert(content)
        output = super
        type = document.type
        extra = {}
        extra[:output] = document.tempfile.path if document.binary?

        content = <<~EOD
          #{Utils.sanitize_data(document.data).to_yaml}
          ---

          #{output}
        EOD

        File.open(File.join('/tmp', document.relative_path), 'w') do |f|
          f.write content
        end

        ParuHelper.from(from: document.extname.sub('.', ''), to: type, **site.config['pandoc'].options[type],
                        **extra) << content
      end

      # Don't convert Markdown to HTML, but do convert everything else
      #
      # @return [array]
      def converters
        @converters ||= super.reject do |c|
          c.instance_of?(Jekyll::Converters::Markdown) || c.instance_of?(Jekyll::Pandoc::Converter)
        end
      end

      # Output extension
      #
      # @return [String]
      def output_ext
        @output_ext ||= ".#{document.type}"
      end

      # Do nothing
      def assign_pages!; end
    end
  end
end
