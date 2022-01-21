# frozen_string_literal: true

require 'test_helper'
require 'jekyll/converters/pandoc'

class Jekyll::Converters::PandocTest < MiniTest::Test
  context 'A site configured for pandoc converter' do
    should 'use pandoc' do
      site = fixture_site 'markdown' => 'Pandoc'

      converter = site.converters.find do |c|
        c.class == Jekyll::Converters::Markdown
      end

      assert converter.setup
      assert_includes converter.third_party_processors, :Pandoc
      assert_instance_of Jekyll::Converters::Markdown::Pandoc, converter.instance_variable_get(:@parser)
    end

    should 'convert markdown using pandoc' do
      site = fixture_site 'markdown' => 'Pandoc'

      converter = site.converters.find do |c|
        c.class == Jekyll::Converters::Markdown
      end

      assert converter.setup
      assert_equal "<h1 id=\"hello\">Hello</h1>\n", converter.convert('# Hello')
    end
  end
end
