# frozen_string_literal: true

require 'paru/pandoc'

module Jekyll
  module Pandoc
    # Creates a Paru::Pandoc with options from configuration
    module ParuHelper
      extend self

      # Returns a Paru::Pandoc with options set
      #
      # @param [Hash]
      # @return [Paru::Pandoc]
      def from(options)
        Paru::Pandoc.new.tap do |paru|
          options.each do |option, value|
            paru.send option, value
          end
        end
      end
    end
  end
end
