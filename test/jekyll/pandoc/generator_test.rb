# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/generator'

class Jekyll::Pandoc::GeneratorTest < MiniTest::Test
  context 'A Pandoc generator' do
    setup do
      @site = fixture_site(**site_configuration).tap(&:read)
      @generator = @site.generators.first
      @generator.generate(@site)
    end

    should 'generate collections for formats' do
      collection = @generator.send(:collection_for, 'pdf')

      assert_equal 'pdf', collection.label
      assert_equal @site.posts.url_template, collection.metadata['permalink']
      assert collection.metadata['output']
      assert_equal collection, @site.collections['pdf']
    end

    should 'keep the same collection for the same format' do
      collection = @generator.send(:collection_for, 'pdf')
      collection2 = @generator.send(:collection_for, 'pdf')

      assert_equal collection, collection2
    end

    should 'not generate' do
      assert_equal false, @generator.send(:generate?)
    end

    should 'tell people to implement their own generators' do
      assert_raises NotImplementedError do
        @generator.send(:source_documents)
      end

      assert_raises NotImplementedError do
        @generator.send(:generate_documents!)
      end
    end

    should 'follow collections manual configuration' do
      assert_equal @site.config.dig('collections', 'rst', 'permalink'),
                   @generator.send(:collection_for, 'rst').metadata['permalink']
    end
  end
end
