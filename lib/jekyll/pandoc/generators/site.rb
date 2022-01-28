# frozen_string_literal: true

require_relative '../generator'
require_relative 'multiple'

module Jekyll
  module Pandoc
    module Generators
      class Site < Jekyll::Pandoc::Generator
        include Multiple

        priority :high

        private

        # All posts
        #
        # @return [String]
        def generator_type
          @generator_type ||= 'site'
        end

        # All posts
        #
        # @return [Array]
        def source_documents
          @source_documents ||= [ [ site.config['title'], site.posts.docs.reject(&:asset_file?) ] ]
        end
      end
    end
  end
end
