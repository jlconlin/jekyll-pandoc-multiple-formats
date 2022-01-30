# frozen_string_literal: true

require 'securerandom'
require 'jekyll/utils'
require_relative '../document'
require_relative '../utils'

module Jekyll
  module Pandoc
    module Documents
      # A document composed of several documents
      class Multiple < Jekyll::Pandoc::Document
        # Documents group
        #
        # @return [Array]
        attr_reader :source_documents

        # @param path [String]
        # @param relations [Hash]
        def initialize(path, relations = {})
          @source_documents = relations[:source_documents]
          relations[:source_document] = self
          super

          Jekyll::Utils.deep_merge_hashes!(data, relations[:data])
        end

        # Data must be provided externally
        #
        # @return [Hash]
        def data
          @data ||= { 'multiple' => true }
        end

        # The content is a concatenated string of source_documents
        # content with their titles.
        #
        # The ID is attached to a title so you can map IDs to metadata
        # on a Pandoc filter later.
        #
        # @return [nil]
        def read_content(**)
          self.content = source_documents.map do |doc|
            ["\n\n# #{doc['title']} {##{extract_id(doc)} data-chapter-title=true}", doc.content]
          end.flatten.join("\n\n")

          nil
        end

        # Generates a data hash from source documents so they can be
        # accessed later as Pandoc metadata.  For instance, to generate
        # authors per chapter.
        #
        # @return [nil]
        def read_post_data
          data['uuid'] ||= SecureRandom.uuid

          source_documents.each do |doc|
            data[extract_id(doc)] = Jekyll::Pandoc::Utils.sanitize_data doc.data
          end

          nil
        end

        private

        # Extracts an ID from a document
        #
        # @return [String]
        def extract_id(document)
          document['uuid'] || document.id.tr('/', '-').sub(/\A-/, '')
        end
      end
    end
  end
end
