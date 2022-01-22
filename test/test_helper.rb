# frozen_string_literal: true

require 'minitest/autorun'
require 'jekyll'
require 'shoulda'

class Minitest::Test
  def fixture_site(**extra)
    config = {
      'source' => site_source_directory,
      'destination' => site_destination_directory
    }

    Jekyll::Site.new(Jekyll::Configuration.from(
                       [Jekyll::Configuration::DEFAULTS, config, extra].reduce do |c, n|
                         Jekyll::Utils.deep_merge_hashes(c, n)
                       end
                     ))
  end

  def current_directory
    @current_directory ||= File.join(Dir.pwd, 'test')
  end

  def site_source_directory
    @site_source_directory ||= File.join(current_directory, 'source')
  end

  def site_destination_directory
    @site_destination_directory ||= File.join(current_directory, 'destination')
  end

  def site_configuration
    @site_configuration ||= YAML.safe_load(File.read(File.join(site_source_directory, '_config.yml')))
  end
end
