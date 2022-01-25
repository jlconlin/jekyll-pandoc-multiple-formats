# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/document'

class Jekyll::Pandoc::DocumentTest < MiniTest::Test
  context 'A Jekyll document' do
    setup do
      @site = fixture_site(**site_configuration).tap(&:read)
      @source_document = @site.posts.docs.sample

      @collection = Jekyll::Collection.new(@site, 'pdf').tap do |col|
        @site.collections['pdf'] = col
      end

      @document = Jekyll::Pandoc::Document.new @source_document.path, collection: @collection,
                                                                      source_document: @source_document, site: @site
    end

    should 'not be considered an asset file' do
      assert_equal false, @document.sass_file?
      assert_equal false, @document.coffeescript_file?
      assert_equal false, @document.asset_file?
    end

    should 'not be placed in a layout' do
      assert_equal false, @document.place_in_layout?
    end

    should 'be binary if pdf' do
      assert @document.binary?
    end

    should 'have a format' do
      assert_equal '.pdf', @document.output_ext
      assert @document.destination(@site.dest).end_with?('.pdf')
    end

    should 'remove the source collection directory from path' do
      assert_equal false, @document.destination(@site.dest).include?('_posts')
      assert_equal @source_document.cleaned_relative_path, @document.cleaned_relative_path
    end
  end
end
