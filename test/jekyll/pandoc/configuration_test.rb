# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/configuration'

class Jekyll::Pandoc::ConfigurationTest < MiniTest::Test
  context 'A site configured for pandoc' do
    setup do
      @site = fixture_site(**site_configuration)
      @configuration = Jekyll::Pandoc::Configuration.new(@site)
    end

    should 'find its own config' do
      assert @configuration.config
    end

    should 'detect available formats' do
      assert_equal %i[html5 mediawiki rst pdf epub latex], @configuration.available_formats
    end

    should 'detect current locale' do
      assert_equal 'es', @configuration.current_locale
    end

    should 'be processed before having options' do
      assert @configuration.options.empty?
    end

    should 'process options' do
      @configuration.process

      assert_equal false, @configuration.options.empty?
    end

    should 'contain common options in all formats, except removed or changed' do
      @configuration.process

      common = @configuration.config.dig('options', 'common')

      @configuration.available_formats.each do |format|
        options = @configuration.options[format]

        assert options
        case format
        when 'html5'
          assert_equal common.slice(*(options.keys - %i[toc-depth])), options.slice(*(common.keys - %i[toc-depth]))
        else
          assert_equal common.slice(*options.keys), options.slice(*common.keys)
        end
      end
    end

    should 'remove options disabled on other levels' do
      @configuration.process

      assert_nil @configuration.options.dig(*%i[pdf toc-depth])
    end
  end

  context 'A site in another language' do
    setup do
      @site = fixture_site(**site_configuration, 'lang' => 'ar')
      @configuration = Jekyll::Pandoc::Configuration.new(@site)
    end

    should 'include locale-specific flags' do
      @configuration.process

      assert_equal 'Amiri', @configuration.options.dig(*%i[pdf variables mainfont])
    end
  end
end
