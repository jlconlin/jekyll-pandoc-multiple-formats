# frozen_string_literal: true

require 'jekyll/utils'

module Jekyll
  module Pandoc
    # Processes Pandoc configuration by merging common, per format and
    # current locale options.
    #
    # There's no default configuration.
    class Configuration
      extend Forwardable

      SPECIAL_OPTIONS = %w[common locales].freeze

      # Jekyll site
      #
      # @return [Jekyll::Site]
      attr_reader :site

      # Processed options
      #
      # @return [Hash]
      attr_reader :options

      # Delegate key accessors to config
      def_delegators :config, :[], :dig

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
        @available_formats ||= ((config['options']&.keys || []) - SPECIAL_OPTIONS).map(&:to_sym).freeze
      end

      # Find PDF papersize
      #
      # @return [Symbol]
      def papersize
        @papersize ||= options.dig(:pdf, :variable).find do |v|
          v.start_with? 'papersize='
        end&.split('=', 2)&.last&.to_sym
      end

      # Merge all options and remove the ones disabled
      #
      # TODO: Process common first so it's not done for every format.
      #
      # @return [nil]
      def process
        return unless options.empty?

        available_formats.each do |format|
          options[format] =
            paru_options(disable_options(reduce_options(format.to_s)))
        end

        nil
      end

      private

      # @param [String]
      # @return [Hash]
      def reduce_options(format)
        [
          config.dig('options', 'common'),
          config.dig('options', 'locales', current_locale, 'common'),
          config.dig('options', format),
          config.dig('options', 'locales', current_locale)
        ].compact.reduce do |config, next_config|
          next_config = {} if next_config == true

          Jekyll::Utils.deep_merge_hashes(config, next_config)
        end
      end

      # Removes options with non truthy values
      #
      # @param [Hash,nil]
      # @return [Hash,nil]
      def disable_options(options)
        options&.select do |_, v|
          v
        end
      end

      # Convert options to Paru methods
      #
      # @param [Hash,nil]
      # @return [Hash,nil]
      def paru_options(options)
        options&.transform_keys do |k|
          k.gsub('-', '_').to_sym
        end
      end
    end
  end
end
