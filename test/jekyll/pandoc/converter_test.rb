# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/configuration'
require 'jekyll/pandoc/converter'

class Jekyll::Pandoc::ConverterTest < MiniTest::Test
  context 'A site configured for pandoc converter' do
    setup do
      @site = fixture_site(**site_configuration)
      @configuration = Jekyll::Pandoc::Configuration.new(@site)
      @converter = @site.converters.find do |c|
        c.instance_of? Jekyll::Converters::Markdown
      end

      @configuration.process
    end

    should 'use pandoc' do
      assert @converter.setup
      assert_includes @converter.third_party_processors, :Pandoc
      assert_instance_of Jekyll::Converters::Markdown::Pandoc, @converter.instance_variable_get(:@parser)
    end

    should 'convert markdown using pandoc' do
      assert @converter.setup
      assert_equal "<section id=\"hello\" class=\"level1\">\n<h1>Hello</h1>\n</section>\n", @converter.convert('# Hello')
    end
  end
end
