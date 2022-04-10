# frozen_string_literal: true

require 'jekyll/converter'
require_relative 'paru_helper'

module Jekyll
  module Pandoc
    module Converter
      # Input formats supported by Pandoc that make sense to convert
      # into HTML.
      #
      # @return [Array]

      # @param ext [String]
      # @return [Boolean]
      def matches(ext)
        ".#{self.class::EXT}" == ext.downcase
      end

      # Convert into HTML
      #
      # @return [String]
      def output_ext(_)
        '.html'
      end

      # @param content [String]
      # @return [String]
      def convert(content)
        parser << content
      end

      private

      # Generates a parser from config
      #
      # @return [Paru::Pandoc]
      def parser
        @parser ||= ParuHelper.from(from: self.class::EXT, to: 'html5', metadata: 'title=Jekyll',
                                    **@config['pandoc'].options[:html5])
      end
    end
  end
end

%w[creole docbook docx dokuwiki haddock ipnyb jira mediawiki man muse odt org rst t2t textile tikiwiki twiki
   vimwiki].each do |format|
  converter = Class.new(Jekyll::Converter)
  converter.class_exec(format) do |f|
    const_set :EXT, f

    include Jekyll::Pandoc::Converter

    safe true
  end

  Object.const_set format.capitalize, converter
end
