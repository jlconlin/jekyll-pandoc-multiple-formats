# frozen_string_literal: true

require_relative '../renderer'
require_relative '../printing'

module Jekyll
  module Pandoc
    module Renderers
      # Applies binder imposition to a PDF document
      class Binder < Jekyll::Pandoc::Renderer
        include Jekyll::Pandoc::Printing

        # @return [String]
        def output_ext
          @output_ext ||= '-bound.pdf'
        end

        private

        # Generates page order for binding, taking into account how many
        # pages fit per sheet.
        #
        # @return [Array]
        def pages
          @pages ||= (1..page_count).map do |page|
            [page] * nup
          end.flatten
        end
      end
    end
  end
end
