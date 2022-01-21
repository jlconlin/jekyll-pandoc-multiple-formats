# frozen_string_literal: true

require 'minitest/autorun'
require 'jekyll'
require 'shoulda'

class Minitest::Test
  def fixture_site(**extra)
    current_dir = File.join(Dir.pwd, 'test')

    config = {
      'source' => File.join(current_dir, 'source'),
      'destination' => File.join(current_dir, 'destination')
    }

    Jekyll::Site.new(
      [Jekyll::Configuration::DEFAULTS, config, extra].reduce do |c, n|
        Jekyll::Utils.deep_merge_hashes(c, n)
      end
    )
  end
end
