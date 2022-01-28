# frozen_string_literal: true

require_relative '../document'
require_relative '../renderers/binder'

module Jekyll
  module Pandoc
    module Documents
      # A bound document is printed, cut and bound with pegament (or
      # sewn, etc.)
      class Bound < Jekyll::Pandoc::Document
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

          source_document.source_document.data['bound'] =
            source_document.data['bound'] = self

          source_document.source_document.data['formats'] << self

          nil
        end

        # Binding
        #
        # @return [Jekyll::Pandoc::Renderers::Binder]
        def renderer
          @renderer ||= Jekyll::Pandoc::Renderers::Binder.new(site, self)
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
