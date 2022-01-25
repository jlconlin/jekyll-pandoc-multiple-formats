# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/configuration'
require 'jekyll/pandoc/document'
require 'jekyll/pandoc/renderer'

class Jekyll::Pandoc::RendererTest < MiniTest::Test
  context 'A Jekyll renderer' do
    setup do
      @site = fixture_site(**site_configuration).tap(&:read)
      @site.config['pandoc'] = Jekyll::Pandoc::Configuration.new(@site).tap(&:process)
      @source_document = @site.posts.docs.first

      @collection = Jekyll::Collection.new(@site, 'mediawiki').tap do |col|
        @site.collections['mediawiki'] = col
      end

      @document = Jekyll::Pandoc::Document.new @source_document.path, collection: @collection,
                                                                      source_document: @source_document, site: @site
    end

    should 'not convert from markdown to HTML' do
      assert_equal 1, @document.renderer.converters.size
      assert_instance_of Jekyll::Converters::Identity, @document.renderer.converters.first
    end

    should 'have an output extension based on the format' do
      assert_equal '.mediawiki', @document.renderer.output_ext
    end

    should 'render content using pandoc' do
      @document.read
      assert_equal "= A Title =\n\nSome text.\n", @document.renderer.run
    end
  end
end
