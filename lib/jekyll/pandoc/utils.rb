# frozen_string_literal: true

require 'open3'

module Jekyll
  module Pandoc
    # Finds external commands
    module Utils
      extend self

      # Remove these keys from {#data}
      #
      # @return [Array]
      EXCLUDED_DATA = %w[excerpt permalink].freeze

      # Remove and transform values for safe YAML dumping.
      #
      # Copied almost verbatim from jekyll-linked-posts
      #
      # @return [Hash]
      def sanitize_data(data)
        data.reject do |k, _|
          EXCLUDED_DATA.include? k
        end.transform_values do |value|
          case value
          when Jekyll::Document
            value.data['uuid']
          when Jekyll::Convertible
            value.data['uuid']
          when Set
            value.map do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          when Array
            value.map do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          when Hash
            value.transform_values do |v|
              v.respond_to?(:data) ? v.data['uuid'] : v
            end
          else
            value
          end
        end
      end

      # Yes, we do respond to any method called.
      def respond_to_missing?(_, _)
        true
      end

      # Allow to call #program_name and #program_name? instead of calling
      # `which` everytime.
      def method_missing(name, *_args)
        n = name.to_s.sub(/\?\z/, '').to_sym

        define_method(n) do
          which n.to_s
        end

        define_method(:"#{n}?") do
          !which(n.to_s).empty?
        rescue ArgumentError
          false
        end

        public_send name
      end

      # Find a program in PATH by name or throw an error
      #
      # @param util [String] Program name
      # @return [String] Program path
      def which(util)
        @which_cache ||= {}
        @which_cache[util] ||=
          begin
            result = nil

            Open3.popen2('which', util) do |stdin, stdout, thread|
              stdin.close
              result = stdout.read.strip

              unless thread.value.success?
                raise ArgumentError, "Couldn't find #{util} on your PATH, maybe you need to install it?"
              end
            end

            result
          end
      end
    end
  end
end
