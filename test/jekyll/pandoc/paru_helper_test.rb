# frozen_string_literal: true

require 'test_helper'
require 'jekyll/pandoc/paru_helper'

class Jekyll::Pandoc::ParuHelperTest < MiniTest::Test
  context 'The Paru helper' do
    should 'configure itself from an options hash' do
      options = {'from'=>'markdown', 'to'=>'html5'}
      paru = Jekyll::Pandoc::ParuHelper.from(from: 'markdown', to: 'html5')

      assert_instance_of Paru::Pandoc, paru
      assert_equal options, paru.instance_variable_get(:@options)
    end

    should 'ignore variables' do
      options = {'from'=>'markdown', 'to'=>'html5'}
      paru = Jekyll::Pandoc::ParuHelper.from(from: 'markdown', to: 'html5', variables: { title: 'Hola' })

      assert_equal options, paru.instance_variable_get(:@options)
    end
  end
end
