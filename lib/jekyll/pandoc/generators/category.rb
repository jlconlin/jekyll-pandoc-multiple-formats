# frozen_string_literal: true

require_relative '../generator'
require_relative 'multiple'

module Jekyll
  module Pandoc
    module Generators
      class Category < Jekyll::Pandoc::Generator
        include Multiple

        priority :high

        private

        # Group posts by categories
        #
        # @return [String]
        def generator_type
          @generator_type ||= 'categories'
        end

        # Groups documents by category
        #
        # @return [Array]
        def source_documents
          @source_documents ||= site.categories.to_a
        end
      end
    end
  end
end
