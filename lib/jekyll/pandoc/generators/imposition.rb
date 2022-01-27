# frozen_string_literal: true

require_relative '../generator'
require_relative '../documents/imposed'

module Jekyll
  module Pandoc
    module Generators
      # Generates a ready for print PDF by creating 4-pages sheets.
      class Imposition < Jekyll::Pandoc::Generator
        priority :high

        private

        # Only generate if the site asks for imposition
        #
        # @return [Boolean]
        def generate?
          site.config.dig('pandoc', 'printing', 'formats')&.include? 'imposition'
        end

        # Only PDFs are imposed
        #
        # @return [Array]
        def source_documents
          @source_documents ||= site.collections['pdf'].docs
        end

        # Generate a {Jekyll::Pandoc::Documents::Imposed} per document
        #
        # @return [nil]
        def generate_documents!
          source_documents.each do |document|
            collection_for('imposed').tap do |col|
              col.docs << Jekyll::Pandoc::Documents::Imposed.new(document.path, site: site, collection: col,
                                                                                source_document: document).tap(&:read)
            end
          end

          nil
        end
      end
    end
  end
end
