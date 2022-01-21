# frozen_string_literal: true

require 'test_helper'
require 'jekyll-pandoc-multiple-formats/utils'

class JekyllPandocMultipleFormats::UtilsTest < MiniTest::Test
  context 'I need some utils installed' do
    should 'find anything we need' do
      assert JekyllPandocMultipleFormats::Utils.pandoc?
      assert JekyllPandocMultipleFormats::Utils.pdfinfo?
      assert JekyllPandocMultipleFormats::Utils.tectonic?
    end

    should "fail if they're missing" do
      assert_raises ArgumentError do
        JekyllPandocMultipleFormats::Utils.doesnt_exist
      end
    end

    should 'return false when asked if present an is not' do
      assert_equal false, JekyllPandocMultipleFormats::Utils.doesnt_exist?
    end
  end
end
