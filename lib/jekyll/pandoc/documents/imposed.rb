# frozen_string_literal: true

require 'securerandom'
require_relative '../document'
require_relative '../renderers/imposition'

module Jekyll
  module Pandoc
    module Documents
      # An imposed document is a PDF with pages arranged for printing
      # and folding.
      class Imposed < Jekyll::Pandoc::Document
        # Do nothing, content is not read, but Jekyll expects a String
        #
        # @return [nil]
        def read_content(**)
          self.content = ''
          nil
        end

        # Adds relations to source documents
        #
        # @return [nil]
        def read_post_data
          if data.key? 'uuid'
            require 'securerandom'
            data['uuid'] = SecureRandom.uuid
          end

          source_document.source_document.data['imposed'] =
            source_document.data['imposed'] = self

          source_document.source_document.data['formats'] << self

          nil
        end

        # Imposition
        #
        # @return [Jekyll::Pandoc::Renderers::Imposition]
        def renderer
          @renderer ||= Jekyll::Pandoc::Renderers::Imposition.new(site, self)
        end

        # The file is always binary
        #
        # @return [TrueClass]
        def binary?
          true
        end

        # PDFs can't be rendered with Liquid
        #
        # @return [FalseClass]
        def render_with_liquid?
          false
        end
      end
    end
  end
end
