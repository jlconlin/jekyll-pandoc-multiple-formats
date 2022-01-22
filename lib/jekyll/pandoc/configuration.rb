# frozen_string_literal: true

require 'jekyll/utils'

module Jekyll
  module Pandoc
    # Processes Pandoc configuration by merging common, per format and
    # current locale options.
    #
    # There's no default configuration.
    class Configuration
      SPECIAL_OPTIONS = %w[common locales].freeze

      # Jekyll site
      #
      # @return [Jekyll::Site]
      attr_reader :site

      # Processed options
      #
      # @return [Hash]
      attr_reader :options

      # @param [Jekyll::Site]
      def initialize(site)
        @site = site
        @options = {}
      end

      # Configuration from site
      #
      # @return [Hash]
      def config
        @config ||= site.config['pandoc'] || {}
      end

      # Current locale.  If you're using jekyll-locales, the site will
      # be built once per locale, so the locale will be configured.
      #
      # @return [String,nil]
      def current_locale
        @current_locale ||= site.config['lang'] || site.config['locale']
      end

      # Available formats
      #
      # @return [Array]
      def available_formats
        @available_formats ||= ((config['options']&.keys || []) - SPECIAL_OPTIONS).freeze
      end

      # Merge all options and remove the ones disabled
      #
      # TODO: Process common first so it's not done for every format.
      #
      # @return [nil]
      def process
        available_formats.each do |format|
          options[format] =
            [
              config.dig('options', 'common'),
              config.dig('options', 'locales', current_locale, 'common'),
              config.dig('options', format),
              config.dig('options', 'locales', current_locale, format)
            ].compact.reduce do |config, next_config|
              next_config = {} if next_config == true

              Jekyll::Utils.deep_merge_hashes(config, next_config)
            end.select do |_, value|
              value
            end
        end

        nil
      end
    end
  end
end
