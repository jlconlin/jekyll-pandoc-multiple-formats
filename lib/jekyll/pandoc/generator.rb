# frozen_string_literal: true

module Jekyll
  module Pandoc
    # Generates all Pandoc documents and adds them to the site.  The
    # documents are not written, just prepared for later rendering and
    # writing following Jekyll's process.
    #
    # @see Jekyll::Site#generate
    # @see Jekyll::Generator
    class Generator < ::Jekyll::Generator
      safe true
      priority :highest

      # Site
      #
      # @return [Jekyll::Site]
      attr_reader :site

      # Pandoc collections
      #
      # @return [Hash]
      attr_reader :collections

      # Generate documents for every format.
      #
      # @return [nil]
      def generate(site)
        @site = site
        @collections = {}

        return unless generate?

        setup
        generate_documents!
      end

      private

      # Do nothing for now
      def setup; end

      # Source documents.  Every generator know how to fetch its own
      # documents.
      #
      # @return [Array]
      def source_documents
        raise NotImplementedError
      end

      # This method knows how to collect documents, and generate
      # collections and Pandoc documents.
      #
      # @return [nil]
      def generate_documents!
        raise NotImplementedError
      end

      # @return [Hash]
      def config
        site.config['pandoc']
      end

      # Jekyll runs every Jekyll::Generator descendant, but we don't
      # want to run this one, just use it as a template.
      #
      # @return [Boolean]
      def generate?
        self.class != Jekyll::Pandoc::Generator
      end

      # Creates or finds a collection by a label, performs basic
      # configuration and brings everything else from site
      # configuration.
      #
      # @param label [String]
      # @return [Hash]
      def collection_for(label)
        @collections[label] ||= Jekyll::Collection.new(site, label).tap do |col|
          site.collections[label] = col
          # Allow to configure the collection
          # @see https://jekyllrb.com/docs/collections/
          col.metadata['output'] = true unless col.metadata.key? 'output'
          # Follow the same permalink structure unless otherwise
          # specified.
          col.metadata['permalink'] = site.posts.url_template unless site.config.dig('collections', label, 'permalink')
        end
      end
    end
  end
end
