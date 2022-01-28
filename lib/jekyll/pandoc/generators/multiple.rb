# frozen_string_literal: true

require 'tempfile'
require 'jekyll/utils'
require_relative '../documents/multiple'

module Jekyll
  module Pandoc
    module Generators
      # Mixin for multiple-file generators
      module Multiple
        private

        # Generator type
        #
        # @return [String]
        def generator_type
          raise NotImplementedError
        end

        # Must return an Array of grouped documents (an Array of Arrays)
        #
        # @return [Array]
        def source_documents
          raise NotImplementedError
        end

        # @return [Boolean]
        def generate?
          config['documents']&.include? generator_type
        end

        # Generates a temporary file on site source per each document
        # group and passes data as a relation.
        #
        # @return [nil]
        def generate_documents!
          source_documents.each do |(title, documents)|
            config.available_formats.each do |format|
              next if format == :html5

              data = {
                'title' => title,
                'slug' => Jekyll::Utils.slugify(title, mode: 'pretty'),
                'data' => Time.now
              }
              label = format.to_s
              file = Tempfile.new([data['slug'], '.markdown'], site.source)

              collection_for(label).tap do |col|
                col.docs << Jekyll::Pandoc::Documents::Multiple.new(file.path, site: site, collection: col,
                                                                               source_documents: documents, data: data).tap(&:read)
              end
            end
          end

          nil
        end
      end
    end
  end
end
