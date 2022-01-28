# frozen_string_literal: true

require 'tempfile'
require 'jekyll/document'
require_relative 'renderer'

module Jekyll
  module Pandoc
    # Represents a single document.  Extends Jekyll::Document since it's
    # the most complete class for managing documents.  Either
    # Convertible or Page are too constrained and would require to
    # rewrite a lot of code.
    class Document < Jekyll::Document
      # Binary formats are treated specially because Pandoc writes them
      # to disk, unless we were to use - as output file and read
      # everything into memory.
      #
      # @return [Array]
      BINARY_FORMATS = %i[pdf epub epub3 fb2 docx odt].freeze

      # Remove these keys from {#data}
      #
      # @return [Array]
      EXCLUDED_DATA = %w[excerpt permalink].freeze

      # Site
      #
      # @return [Jekyll::Site]
      attr_reader :site

      # Collection
      #
      # @return [Jekyll::Collection]
      attr_reader :collection

      # Source document
      #
      # @return [Jekyll::Document]
      attr_reader :source_document

      # Content
      #
      # @return [String]
      attr_accessor :content

      # Output.  Empty string if the file is in binary format
      #
      # @return [String]
      attr_accessor :output

      # @param [String]
      # @param [Hash]
      def initialize(path, relations = {})
        @source_document = relations[:source_document]
        super
      end

      # Remove collection directory too so Jekyll doesn't confuse it
      # with a category
      #
      # @return [String]
      def relative_path
        @relative_path ||= super.sub(source_document.collection.relative_directory, '')
      end

      # Temporary file where Pandoc writes binary formats
      #
      # @return [Tempfile]
      def tempfile
        @tempfile ||= Tempfile.new([data['slug'], output_ext])
      end

      # The path where the renderer wrote the actual contents for binary
      # files.
      #
      # @return [String]
      def rendered_path
        tempfile.path
      end

      # Clone data from the source document
      #
      # @return [Hash]
      def data
        @data ||= source_document.data.dup
      end

      # Remove and transform values for safe YAML dumping.
      #
      # Copied almost verbatim from jekyll-linked-posts
      #
      # @return [Hash]
      def sanitize_data(data)
        data.reject do |k, _|
          EXCLUDED_DATA.include? k
        end.transform_values do |value|
          case value
          when Jekyll::Document
            value.data['uuid']
          when Jekyll::Convertible
            value.data['uuid']
          when Set
            value.map do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          when Array
            value.map do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          when Hash
            value.transform_values do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          else
            value
          end
        end
      end

      # Do nothing
      def merge_defaults; end

      # Duplicate the content
      #
      # @return [nil]
      def read_content(**)
        self.content = source_document.content.dup

        nil
      end

      # "Read" data and adds itself to the source document data.
      #
      # @return [nil]
      def read_post_data
        # Assign a new UUIDv4 if the source document has one.
        #
        # TODO: How to assign the same UUID to every document?
        if data.key? 'uuid'
          require 'securerandom'
          data['uuid'] = SecureRandom.uuid
        end

        source_document.data['formats'] ||= []
        source_document.data['formats']  << self
        # Can't guarantee the front matter won't use the same key
        source_document.data[collection.label] ||= self

        nil
      end

      # The renderer will know how to convert this document to the
      # needed format.
      #
      # @return [Jekyll::Pandoc::Renderer]
      def renderer
        @renderer ||= Renderer.new(site, self)
      end

      # If the format is binary, we need to copy the tempfile to the
      # destination.
      #
      # @return [nil]
      def write(dest)
        super

        return unless binary?

        path = destination(dest)

        FileUtils.rm path
        FileUtils.cp rendered_path, path

        nil
      end

      # Detect if the format is binary.  The type is set from the
      # collection label, which in turn is the Pandoc-supported format.
      #
      # @return [Boolean]
      def binary?
        BINARY_FORMATS.include? type
      end

      # Generate the destination from the URL and change .html to the
      # output extension.
      #
      # @return [String]
      def destination(dest)
        super.sub(/\.html\z/, output_ext)
      end

      # We don't have layouts (yet?)
      #
      # @return [FalseClass]
      def place_in_layout?
        false
      end

      # It's not an asset...
      #
      # @return [FalseClass]
      def asset_file?
        false
      end

      # Nor a SASS file...
      #
      # @return [FalseClass]
      def sass_file?
        false
      end

      # Or a CoffeeScript file...
      #
      # @return [FalseClass]
      def coffeescript_file?
        false
      end

      # No need to generate an excerpt either.
      #
      # @return [FalseClass]
      def generate_excerpt?
        false
      end
    end
  end
end
