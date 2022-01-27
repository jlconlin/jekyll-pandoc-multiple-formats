# frozen_string_literal: true

require_relative '../renderer'
require_relative '../printing'

module Jekyll
  module Pandoc
    module Renderers
      # Applies imposition to a PDF document
      class Imposition < Jekyll::Pandoc::Renderer
        include Jekyll::Pandoc::Printing

        # @return [String]
        def output_ext
          @output_ext ||= '-imposed.pdf'
        end

        private

        # Pages rounded up to the nearest modulo of 4
        #
        # @return [Integer]
        def signed_pages
          @signed_pages ||= (page_count + 3) / 4 * 4
        end

        # The signature is the amount of pages per fold, so it needs to
        # be a modulo of 4.
        #
        # Default is {#page_count} rounded to the next modulo of 4.
        #
        # @return [Integer]
        def signature
          @signature ||= (site.config.dig('pandoc', 'printing', 'signature') || signed_pages).tap do |s|
            raise ArgumentError, 'Signature needs to be modulo of 4' unless (s % 4).zero?
          end
        end

        # Pages that are empty.  At most you'll have 3 empty pages.
        #
        # @return [Integer]
        def blank_pages
          @blank_pages ||= signed_pages - page_count
        end

        # Generates page order for imposition, taking into account how
        # many pages fit per sheet.
        #
        # @return [Array]
        def pages
          # Generate a list of page numbers and pad to signed pages with
          # blank pages.
          padded = (1..page_count).to_a + Array.new(blank_pages, blank_page)

          # Each fold is the size of the signature
          padded.each_slice(signature).map do |fold|
            # And is split in half
            first, last = fold.each_slice(fold.size / 2).to_a

            # Add padding
            last << nil
            # Reverse and split in pairs
            last = last.reverse.each_slice(2)
            # Just split in pairs
            first = first.each_slice(2)

            # Apply page order, for instance a sheet would have pages
            # 20, 1, 2, and 19, and then apply pages on sheet depending
            # on its N-up number.
            #
            # If nup is greater than 2, instead of making this algorithm
            # more complex, we just print nup/2 copies of the PDF.  So
            # you have more to share!
            last.zip(first.to_a).flatten.compact.each_slice(2).map do |pair|
              pair * (nup / 2)
            end
          end.flatten
        end
      end
    end
  end
end
