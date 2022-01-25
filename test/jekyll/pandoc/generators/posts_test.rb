# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/configuration'
require 'jekyll/pandoc/generators/posts'

class Jekyll::Pandoc::Generator::PostsTest < MiniTest::Test
  context 'A Pandoc posts generator' do
    setup do
      @site = fixture_site(**site_configuration).tap(&:read)
      @site.config['pandoc'] = Jekyll::Pandoc::Configuration.new(@site).tap(&:process)
      @generator = @site.generators.last
      @generator.generate(@site)
    end

    should 'generate' do
      assert @generator.send(:generate?)
    end

    should 'not generate if disabled' do
      @site.config['pandoc'].config['documents'] = []

      assert_equal false, @generator.send(:generate?)
    end

    should 'pick source documents from posts' do
      assert_equal 2, @generator.send(:source_documents).size
      assert_equal %w[_posts/2014-01-01-test.markdown _posts/2015-01-01-another_post.markdown],
                   @generator.send(:source_documents).map(&:relative_path)
    end

    should 'not generate an html5 collection' do
      assert_equal false, @generator.collections.key?('html5')
    end

    should 'generate a collection for every format' do
      assert_equal @site.config['pandoc'].available_formats - %i[html5], @generator.collections.keys.map(&:to_sym)
    end

    should 'generate a document for every source document' do
      @generator.collections.each do |_label, collection|
        assert_equal 2, collection.docs.size

        collection.docs.each do |doc|
          @site.posts.docs.include? doc.source_document
        end
      end
    end
  end
end
