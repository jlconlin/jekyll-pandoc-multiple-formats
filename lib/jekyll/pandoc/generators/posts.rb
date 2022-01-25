# frozen_string_literal: true

require_relative '../document'

module Jekyll
  module Pandoc
    class Generator
      # Generates Pandoc documents from Jekyll posts collection.  Each
      # format is a collection.
      class Posts < Generator
        private

        # Only generate if aggregating posts is enabled
        #
        # @return [Boolean]
        def generate?
          config['documents'].include? 'posts'
        end

        # Documents to generate from
        #
        # @return [Array]
        def source_documents
          @source_documents ||= site.posts.docs.reject(&:asset_file?)
        end

        # Generate a Pandoc document for each format and adds it to
        # a collection.
        #
        # HTML5 is already generated by
        # {Jekyll::Converters::Markdown::Pandoc}
        #
        # @return [nil]
        def generate_documents!
          source_documents.each do |document|
            config.available_formats.each do |format|
              next if format == :html5

              collection_for(format.to_s).tap do |col|
                col.docs << Document.new(document.path, site: site, collection: col,
                                                        source_document: document).tap(&:read)
              end
            end
          end

          nil
        end
      end
    end
  end
end
