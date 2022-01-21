# frozen_string_literal: true

module Jekyll
  module Converters
    class Markdown
      # Converts markdown content using Pandoc.
      #
      # A previous iteration of this converter monkeypatched Jekyll (10
      # years ago!).  Now we just use the method Jekyll provides which
      # also provides caching.
      #
      # @see Jekyll::Converters::Markdown
      # @see Jekyll::Converters::Markdown::KramdownParser
      class Pandoc
        # @return [Jekyll::Config]
        attr_reader :config

        # @param [Jekyll::Config]
        def initialize(config)
          require 'paru/pandoc'

          @config = config
        end

        # Convert the content into HTML
        #
        # @param [String] Markdown
        # @return [String] HTML
        def convert(content)
          parser << content
        end

        private

        # Generates a parser from config
        #
        # @return [Paru::Pandoc]
        def parser
          @parser ||= Paru::Pandoc.new do
            from 'markdown+smart'
            to 'html5'
          end
        end
      end
    end
  end
end
