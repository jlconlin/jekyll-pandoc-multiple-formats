# frozen_string_literal: true

require_relative 'jekyll/converters/pandoc'

require 'jekyll-pandoc-multiple-formats/config'

# TODO this may go to a separate gem
require 'jekyll-pandoc-multiple-formats/printer'
require 'jekyll-pandoc-multiple-formats/imposition'
require 'jekyll-pandoc-multiple-formats/binder'
require 'jekyll-pandoc-multiple-formats/unite'

require 'jekyll-pandoc-multiple-formats/pandoc_file'
require 'jekyll-pandoc-multiple-formats/generator'
