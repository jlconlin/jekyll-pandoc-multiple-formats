# frozen_string_literal: true

require 'jekyll/pandoc/paru_helper'

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
        # @return [Jekyll::Configuration]
        attr_reader :config

        # @param config [Jekyll::Configuration]
        def initialize(config)
          @config = config
        end

        # Convert the content into HTML
        #
        # @param content [String] Markdown
        # @return [String] HTML
        def convert(content)
          parser << content
        end

        private

        # Generates a parser from config
        #
        # @return [Paru::Pandoc]
        def parser
          @parser ||= Jekyll::Pandoc::ParuHelper.from(from: 'markdown+smart', to: 'html5',
                                                      **config['pandoc'].options[:html5])
        end
      end
    end
  end
end
