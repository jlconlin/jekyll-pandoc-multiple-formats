# frozen_string_literal: true

require_relative 'jekyll/pandoc/configuration'
require_relative 'jekyll/converters/markdown/pandoc'
require_relative 'jekyll/pandoc/generators/posts'
require_relative 'jekyll/pandoc/generators/imposition'

# We modify the configuration post read, and not after init, because
# Jekyll resets twice and any modification to config will invalidate the
# cache.
Jekyll::Hooks.register :site, :post_read, priority: :high do |site|
  site.config['pandoc'] = Jekyll::Pandoc::Configuration.new(site).tap(&:process)
end
